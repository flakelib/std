with rec {
  bool = import ./bool.nix;
  function = import ./function.nix;
  inherit (function) id flip compose;
  list = import ./list.nix;
  _optional = import ./optional.nix;
};

rec {
  semigroup = {
    append = x: y: x // y;
  };

  monoid = semigroup // {
    inherit empty;
  };

  /* empty :: set
  */
  empty = {};

  /* assign :: key -> value -> set -> set
  */
  assign = k: v: r: r // { "${k}" = v; };

  /* assignAt :: [key] -> value -> set -> set
  */
  assignAt = path: v: r: let
    k = list.head path;
    next = assignAt (list.tail path) v (r.${k} or { });
  in if path == list.nil then v
    else assign k next r;

  /* get :: key -> set -> value
  */
  get = k: s: s.${k};

  /* getOr :: default -> key -> set -> value
  */
  getOr = default: k: s: s.${k} or default;

  /* lookup :: key -> set -> optional value
  */
  lookup = k: s: bool.toOptional (s ? ${k}) s.${k};

  /* lookupAt :: [key] -> set -> optional value
  */
  lookupAt = path: s: list.foldl' (s: k:
    _optional.monad.bind s (lookup k)
  ) (_optional.just s) path;

  /* at :: [key] -> set -> value
  */
  at = path: s: list.foldl' (flip get) s path;

  /* atOr :: default -> [key] -> set -> value
  */
  atOr = default: path: s: _optional.match (lookupAt path s) {
    nothing = default;
    just = id;
  };

  /* optional :: bool -> set -> set

     Optionally keep a set. If the condition is true, return the set
     unchanged, otherwise return an empty set.
  */
  optional = b: s: if b then s else empty;

  match = o: { empty, assign }:
    if o == {}
    then empty
    else match1 o { inherit assign; };

  # O(log(keys))
  match1 = o: { assign }:
    let k = list.head (keys o);
        v = o."${k}";
        r = builtins.removeAttrs o [k];
    in assign k v r;

  /* keys :: set -> [key]
  */
  keys = builtins.attrNames;

  /* values :: set -> [value]
  */
  values = builtins.attrValues;

  /* map :: (key -> value -> value) -> set -> set
  */
  map = builtins.mapAttrs;

  /* mapToList :: (key -> value -> value) -> set -> set
  */
  mapToList = f: compose values (map f);

  /* filter :: (key -> value -> bool) -> set -> set
  */
  filter = f: s: builtins.listToAttrs (list.concatMap (name: let
    value = s.${name};
  in list.optional (f name value) { inherit name value; }) (keys s));

  /* without :: [key] -> set -> set
  */
  without = flip builtins.removeAttrs;

  /* retain :: [key] -> set -> set
  */
  retain = keys: builtins.intersectAttrs (gen keys id);

  /* traverse :: Applicative f => (value -> f
  */
  traverse = ap: f:
    (flip match) {
      empty = ap.pure empty;
      assign = k: v: r: ap.lift2 id (ap.map (assign k) (f v)) (traverse ap f r);
    };

  /* toList :: set -> [(key, value)]
  */
  toList = s: list.map (k: { _0 = k; _1 = s.${k}; }) (keys s);

  /* fromList :: [(key, value)] -> set
  */
  fromList = xs: builtins.listToAttrs (list.map ({ _0, _1 }: { name = _0; value = _1; }) xs);

  /* gen :: [key] -> (key -> value) -> set
  */
  gen = keys: f: fromList (list.map (n: { _0 = n; _1 = f n; }) keys);
}
