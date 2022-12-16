{ lib }: let
  inherit (lib.Std) std;
  inherit (lib)
    Ty Fn Bool Opt Null
    Set List NonEmpty Str Cmp;
  showKeyValue = show: k: v: "${k} = ${show v}; ";
  findType = types: x: (NonEmpty.foldl'
    (c: n: if n.check x then n else c)
    types);
  OfTypes = {
    types
  , fallback ? Fn.const Ty.any
  }: x: let
    types' = types.${Ty.PrimitiveNameOf x} or (NonEmpty.singleton (fallback x));
  in findType types' x;
in {
  # backcompat
  show = Ty.Show;
  of = Ty.Of;

  Show = Ty.any.show;
  PrimitiveNameOf = builtins.typeOf;

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

  compare = Ty.enum [ Cmp.LessThan Cmp.Equal Cmp.GreaterThan ];

  complex = std.types.complex or (Ty.mkType {
    name = "Complex";
    description = "complex number";
    check = x: x ? realPart && x ? imagPart;
    show = x: "${x.realPart}+${x.imagPart}i";
  });

  assertion = lib.Assert.TypeId.ty;
  record = lib.Rec.TypeId.ty;
  system = lib.System.TypeId.ty;

  any = Ty.any' // {
    show = x: (Ty.Of x).show x;
  };

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

  Of = OfTypes {
    fallback = Ty.of';
    types = {
      set = NonEmpty.make Ty.attrs [
        Ty.dyn
        Ty.stringlike
        Ty.function
        Ty.drv
        Ty.flakeInput
        Ty.opt
        Ty.complex
      ];
      string = NonEmpty.make Ty.string [
        Ty.dyn
        Ty.pathlike
      ];
    };
  };

  Of' = x: let
    ty = Ty.of x;
  in if ty == Ty.dyn then (Ty.TypeId.Of x).ty else ty;

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
        nothing = throw "${TypeId.name}: unsupported tag type ${Ty.PrimitiveNameOf x}";
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

  # https://github.com/chessai/nix-std/pull/40
  function = Ty.mkType {
    name = "function";
    description = "function";
    check = f: Ty.lambda.check f || Ty.functionSet.check f;
    show = f: let
      args = Fn.args f;
      showArg = k: isOptional: Bool.ifThenElse isOptional "${k} ? «code»" k;
      body = Str.intercalate ", " (Set.mapToValues showArg args);
      withArgs = "{ " + body + " }: «code»";
    in Bool.ifThenElse (args == { }) "«lambda»" withArgs;
  };
  lambda = Ty.mkType {
    name = "lambda";
    description = "lambda function";
    check = builtins.isFunction;
    inherit (Ty.function) show;
  };
  functionSet = Ty.mkType {
    name = "function ${Ty.attrs.name}";
    description = "callable ${Ty.attrs.description} function";
    check = f: f ? __functor && Ty.function.check f.__functor && Ty.function.check (f.__functor f);
    inherit (Ty.function) show;
  };

  # https://github.com/chessai/nix-std/pull/56
  string = std.types.string // {
    show = Str.escapeNixString;
  };
  stringlike = Ty.mkType {
    name = "stringlike";
    description = "stringlike";
    check = Fn.compose Opt.isJust Str.coerce;
    inherit (Ty.string) show;
  };
  path = std.types.path // {
    check = builtins.isPath;
    show = builtins.toString;
  };
  pathlike = let
    check = x: Str.substring 0 1 (toString x) == "/";
  in Ty.mkType {
      name = "pathlike";
      description = "a pathlike string";
      show = builtins.toString;
      check = x: Ty.stringlike.check x && check x;
    };

  # https://github.com/chessai/nix-std/pull/54
  of' = let
    types = Set.map (_: NonEmpty.singleton) {
      inherit (Ty) bool float int null list path lambda;
    } // {
      set = NonEmpty.make Ty.attrs [
        Ty.functionSet
      ];
      string = NonEmpty.make Ty.string [
        Ty.pathlike
      ];
    };
  in std.types.of or (OfTypes { inherit types; });
  any' = std.types.any or (Ty.mkType {
    name = "any";
    description = "anything";
    check = Fn.const true;
    show = x: (Ty.of' x).show x;
  });
}
