{ lib }: let
  inherit (lib) Set List Bool Opt Fn Ty;
in {
  /* assignAt :: [key] -> value -> set -> set
  */
  assignAt = path: v: r: let
    k = List.head path;
    next = Set.assignAt (List.tail path) v (r.${k} or { });
  in if path == List.nil then v
    else Set.assign k next r;

  /* get :: key -> set -> value
  */
  get = k: s: s.${k};

  /* getOr :: default -> key -> set -> value
  */
  getOr = default: k: s: s.${k} or default;

  /* lookup :: key -> set -> optional value
  */
  lookup = k: s: Bool.toOptional (s ? ${k}) s.${k};

  /* lookupAt :: [key] -> set -> optional value
  */
  lookupAt = path: s: List.foldl' (s: k:
    Opt.monad.bind s (Set.lookup k)
  ) (Opt.just s) path;

  /* at :: [key] -> set -> value
  */
  at = path: s: List.foldl' (Fn.flip Set.get) s path;

  /* atOr :: default -> [key] -> set -> value
  */
  atOr = default: path: s: Opt.match (Set.lookupAt path s) {
    nothing = default;
    just = Fn.id;
  };

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

  Of = Ty.attrsOf;
}
