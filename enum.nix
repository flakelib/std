{ lib }: let
  inherit (lib) Enum List Set Opt Str Fn Ty;
  inherit (Ty) TypeId;
  mapVarName = var:
    if Ty.null.check var then Ty.show var
    else toString var;
in {
  Def = {
    name
  , description ? null
  , show ? null
  , Self ? null
  , meta ? { }
  , var
  }: let
    Self' = if Self != null then Self else res;
    hasNames = ! Ty.list.check var;
    values = if hasNames then Set.values var else var;
    names = if hasNames then Set.keys var else List.map mapVarName var;
    typeid = TypeId.new {
      inherit name;
      ty = Ty.mkType {
        inherit name;
        description = if description != null then description else "enum of ${Str.concatMapSep ", " Ty.show values}";
        show = if show != null then show else Enum.toString Self';
        check = x: toString (TypeId.Of x) == Self'.TypeId.name || List.elem x Self'.TypeId.meta.Values;
      };
      meta = {
        args = {
          inherit var;
        };
        Self = Self';
        Values = values;
        Names = names;
        Attrs = if hasNames then Set.map (_: Self'.TypeId.new) var else { };
      } // meta;
      new = var: var; # TODO: tagged value?
    };
    res = {
      TypeId = typeid;
      inherit (Self'.TypeId.ty) show check;
    } // typeid.meta.Attrs;
  in res;

  __functor = Enum: args: Enum.Def args;

  toString = Self: v: "${Self.TypeId}.${(Enum.nameOfValue Self v).value}";

  values = Self: Self.TypeId.meta.Values;
  names = Self: Self.TypeId.meta.Names;
  tag = Self: v: throw "TODO";

  nameOfValue = Self: v: Opt.map (List.elemAt Self.TypeId.meta.Names) (List.findIndex (x: x == v) Self.TypeId.meta.Values);

  TypeId = throw "TODO";

  Of = Ty.enum;
}
