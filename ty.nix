{ lib }: let
  inherit (lib.Std) std;
  inherit (lib) Ty Assert Fn Opt Null Set List Rec Str Cmp;
  showKeyValue = show: k: v: "${k} = ${show v}; ";
  firstType = fallback: types: x: (List.find (t: t.check x) types).value or fallback;
in {
  show = Ty.any.show;
  Show = Ty.show;

  string = std.types.string // {
    show = Str.escapeNixString;
  };

  stringlike = Ty.mkType {
    name = "stringlike";
    description = "stringlike";
    check = x: Ty.string.check x || x ? __toString; # TODO: consider `outPath`?
  };

  attrs = std.types.attrs // {
    inherit (Ty.attrsOf Ty.any) show;
  };

  list = std.types.list or (Ty.mkType {
    name = "list";
    description = "list";
    check = builtins.isList;
  }) // {
    inherit (Ty.listOf Ty.any) show;
  };

  listOf = type: std.types.listOf type // {
    show = l: "[ ${Str.concatSep ", " (List.map type.show l)} ]";
  };

  attrsOf = std.types.attrsOf or (type: Ty.mkType {
    name = "{${type.name}}";
    description = "attrs of ${type.description}";
    check = x: Ty.attrs.check x && List.all type.check (Set.values x);
    show = x: "{ ${Str.concat (Set.mapToList (showKeyValue type.show) x)}}";
  });

  any = Ty.mkType {
    name = "any";
    description = "anything";
    check = Fn.const true;
    show = x: (Ty.of x).show x;
  };

  pathlike = std.types.path // {
    name = "pathlike";
    description = "path string";
    check = x: Str.is x && Str.substring 0 1 (Str x) == "/";
  };

  path = Ty.mkType {
    name = "path";
    description = "path";
    check = builtins.isPath;
    show = toString;
  };

  flakeInput = Ty.mkType {
    name = "flakeinput";
    description = "flake input";
    check = x: x ? narHash;
    show = x: Ty.attrs.show x.sourceInfo; # TODO
  };

  flake = Ty.mkType {
    name = "flake";
    description = "flake";
    check = x: x ? outputs;
    show = x: Ty.string.show (x.description or "«flake»"); # TODO
  };

  opt = std.types.optional or (Ty.mkType {
    name = "Optional";
    description = "optional";
    check = x: {
      nothing = true;
      just = x ? value;
    }.${x._tag or ""} or false;
    inherit (Ty.optOf Ty.any) show;
  });

  optOf = std.types.optionalOf or (type: Ty.mkType {
    name = "Optional ${type.name}";
    description = "optional of ${type.description}";
    check = x: Ty.opt.check x && Opt.match x {
      nothing = true;
      just = type.check;
    };
    show = x: Opt.match x {
      just = "Just(${type.show x})";
      nothing = "Nothing";
    };
  });

  nonEmptyList = std.types.nonEmptyList or (Ty.mkType {
    name = "NonEmpty";
    description = "non-empty list";
    check = x: Ty.list.check x && x != [];
  });
  nonEmpty = Ty.nonEmptyList;

  compare = Ty.enum [ Cmp.LessThan Cmp.Equal Cmp.GreaterThan ];

  complex = std.types.complex or (Ty.mkType {
    name = "Complex";
    description = "complex number";
    check = x: x ? realPart && x ? imagPart;
    show = x: "${x.realPart}+${x.imagPart}i";
  });

  assertion = Assert.TypeId.ty;

  record = Rec.TypeId.ty;

  dyn = Ty.mkType {
    name = "std:Dyn";
    description = "dynamically typed data";
    check = x: Ty.typeId.check (Ty.TypeId.Of x);
    show = x: (Ty.TypeId.Of x).ty.show x;
  };

  typeId = Ty.mkType {
    name = "std:TypeId";
    description = "Type ID";
    check = x: toString x.${Ty.TypeId.Attr} or null == Ty.typeId.name;
    show = x: "TypeId(${x.name})";
  };

  primitiveNameOf = builtins.typeOf;

  of = x: {
    int = Ty.int;
    float = Ty.float;
    list = Ty.list;
    bool = Ty.bool;
    null = Ty.null;
    lambda = Ty.function;
    set = firstType Ty.attrs [
      Ty.dyn
      Ty.function
      Ty.drv
      Ty.flakeInput
      Ty.opt
      Ty.complex
    ] x;
    string = firstType Ty.string [ Ty.dyn /*Ty.pathlike*/ ] x;
    path = Ty.path;
  }.${Ty.primitiveNameOf x} or (throw "unknown nix type ${builtins.typeOf x}");

  of' = x: let
    ty = Ty.of x;
  in if ty == Ty.drv then (Ty.TypeId.Of x).ty else ty;

  TypeId = let
    inherit (Ty) TypeId;
    Attr = "__typeid";
    ty = Ty.typeId;
    __toString = typeid: typeid.name;
    new = {
      name ? ty.name
    , ty
    , new ? _: throw "${name}.new unsupported"
    , meta ? { }
    }: {
      inherit ty new meta name __toString;
      ${Attr} = TypeId;
    };
  in new {
    inherit ty new;
  } // {
    inherit Attr;
    ForType = ty: TypeId.new {
      inherit ty;
    };

    tag = {
      set = typeid: set: set // {
        ${TypeId.Attr} = typeid;
      };

      fn = typeid: f: TypeId.tag.set typeid (Fn.toFunctor f);

      string = typeid: str: throw "TODO";
      stringlike = typeid: str: TypeId.tag.set typeid {
        __toString = _: str;
      };

      opt = typeid: x:
        if builtins.isAttrs x then Opt.just (TypeId.tag.set typeid x)
        else if builtins.isString x then Opt.just (TypeId.tag.string typeid x)
        else if builtins.isFunction x then Opt.just (TypeId.tag.fn typeid x)
        else Opt.nothing;

      throw = typeid: x: Opt.match (TypeId.tag.opt typeid x) {
        just = Fn.id;
        nothing = throw "${TypeId.name}: unsupported tag type ${builtins.typeOf x}";
      };

      try = typeid: x: Opt.match (TypeId.tag.opt typeid x) {
        just = Fn.id;
        nothing = x;
      };

      __functor = tag: tag.throw;
    };

    OfSet = set: set.${TypeId.Attr};
    OfString = str: null; # TODO
    Of = x: x.${TypeId.Attr} or (
      if builtins.isString x then Ty.TypeId.OfString x
      else null
    );

    For = x: Null.match (TypeId.Of x) {
      nothing = TypeId.ForType (Ty.of x);
      just = Fn.id;
    };
  };
}
