{ lib }: let
  inherit (lib.Std.std) set;
  inherit (lib) Set List Bool Opt Fn Ty;
in {
  # backcompat
  get = set.unsafeGet;
  at = set.unsafeAt;
  lookup = set.get;
  lookupAt = set.at;
  mapToList = set.mapToValues;

  update = Set.semigroup.append;

  intersectOver = builtins.intersectAttrs;
  mapIntersection = f: a: b: Set.map (name: b: f name a.${name} b) (Set.intersectOver a b);

  mergeWith = let
    append = {
      path
    , values
    , canMerge
    , mapToSet
    }: let
      mergeWith = values: Set.mergeWith {
        inherit canMerge mapToSet path;
        sets = List.map (v: (mapToSet path v).value) values;
      };
      mergeUntil = List.findIndex (Fn.not (canMerge path)) values;
      len = List.length values;
    in if len == 0 then { }
    else if len == 1 then List.head values
    else if List.all (canMerge path) values then mergeWith values
    else Opt.match mergeUntil {
      just = i: let
        split = List.splitAt i values;
      in if i > 0
        then mergeWith split._0
        else List.head values;
      nothing = List.head values;
    };
  in {
    canMerge ? path: v: Opt.isJust (mapToSet path v),
    mapToSet ? path: v: Bool.toOptional (Ty.attrs.check v) v,
    path ? [ ],
    sets
  }: Set.mapZip (name: values: append {
    path = path ++ List.One name;
    inherit canMerge mapToSet values;
  }) sets;

  merge = sets: Set.mergeWith {
    inherit sets;
  };
}
