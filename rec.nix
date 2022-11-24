{ lib }: let
  inherit (lib) Rec Set List Null Fn Ty;
  inherit (Rec) Method Field;
  inherit (Ty) TypeId;
  mapMethod = Self: name: method: Method.fn method;
  mapDotMethod = Self: self: name: method: Self.TypeId.meta.methods.${name} self;
  mapMemoMethod = Self: name: method: x: x.__memo.${name};
  mapField = Self: name: field: x: x.${name};
  coercion = Self: coerce: let
    lookup = {
      ${Self.TypeId.name} = Fn.id;
    } // coerce;
  in if Ty.function.check coerce then Self: coerce
    else Self: value: lookup.${toString (TypeId.For value)} or (_: throw "${Self.TypeId.name}: unknown coercion from ${Ty.show value}") value;
in {
  Def = {
    name
  , description ? "${name} record set"
  , check ? Fn.const true
  , show ? null
  , Self ? null
  , fn ? { }
  , fields ? { }
  , coerce ? { }
  , meta ? { }
  }: let
    methods = fn;
    dotMethods = Set.filter (_: Method.expose) methods;
    memoMethods = Set.filter (_: Method.memoize) methods;
    fieldMethods = Set.filter (_: Field.accessor) fields;
    memoAttr = if memoMethods != { } then "__memo" else null;
    Self' = if Self != null then Self else res;

    typeid = TypeId.new {
      inherit name;
      ty = Ty.mkType {
        inherit name description;
        show = if show != null then show else Rec.toString Self';
        check = x: toString x.${TypeId.Attr} or null == Self'.TypeId.name && check x;
      };
      meta = {
        args = {
          inherit methods fields;
        };
        Self = Self';
        methods = Set.map (mapField Self') fieldMethods // Set.map (mapMethod Self') methods;
        fieldKeys = Set.keys fields;
      } // meta;
      new = args: let
        self = args // {
          ${TypeId.Attr} = Self'.TypeId;
          ${memoAttr} = Set.map (mapDotMethod Self' self) memoMethods;
        } // Set.map (mapDotMethod Self' self) dotMethods;
      in self;
    };

    res = {
      TypeId = typeid;
      Type = typeid.ty;
      inherit (typeid.ty) show check;
      ${Null.Iif (coerce != { }) "__functor"} = coercion Self' coerce;
    } // typeid.meta.methods // Set.map (mapMemoMethod Self') memoMethods;
  in res;

  new = Self: Self.TypeId.new;

  fn = Self: Self.TypeId.meta.methods;
  methodArgs = Self: Self.TypeId.meta.args.methods;
  fieldArgs = Self: Self.TypeId.meta.args.fields;

  fields = Self: set: Set.retain (Rec.typeId Self set).meta.fieldKeys set;
  toString = Self: set: "${Self.TypeId}${Ty.attrs.show (Rec.fields Self set)}";

  memoizedValues = Self: set: set.__memo or { };
  typeId = Self: set: Null.match (TypeId.Of set) {
    nothing = Self.TypeId;
    just = Fn.id;
  };

  typeOf = set: Null.functor.map (typeid: typeid.meta.Self or null) (TypeId.Of set);

  Method = {
    fn = method: if Ty.function.check method then Fn.toLambda method else method.fn;

    memoize = method: method.memoize or false;

    expose = method: method.expose or false;

    # TODO: set pattern methods can specify a named argument for itself instead of first arg

    TypeId = TypeId.new {
      ty = Ty.mkType {
        name = "std:Rec.Method";
        description = "record set method";
        check = x: x ? fn || Ty.function.check x;
      };
    };
  };

  Field = {
    accessor = field: field.accessor or false;
    type = field: field.type or Ty.any;
    default = Set.lookup "default";

    TypeId = TypeId.new {
      ty = Ty.mkType {
        name = "std:Rec.Field";
        description = "record set field";
        check = Ty.attrs.check;
      };
    };
  };

  TypeId = TypeId.new {
    ty = Ty.mkType {
      name = "std:Rec";
      description = "record set";
      check = Ty.attrs.check;
    };
  };
}
