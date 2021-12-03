with { std = import ./../../default.nix; };
with std;

with (import ./../framework.nix);

let
  testSet = { a = 0; b = 1; c = 2; };
in section "std.set" {
  empty = assertEqual set.empty {};
  keys = assertEqual ["a" "b" "c"] (set.keys testSet);
  values = assertEqual [0 1 2] (set.values testSet);
  map = assertEqual { a = 1; b = 2; c = 3; } (set.map (_: num.add 1) testSet);
  mapToList = assertEqual [ 1 2 3 ] (set.mapToList (_: num.add 1) testSet);
  filter = assertEqual { b = 1; } (set.filter (k: v: v == 1) testSet);
  toList = assertEqual [
    { _0 = "a"; _1 = 0; }
    { _0 = "b"; _1 = 1; }
    { _0 = "c"; _1 = 2; }
  ] (set.toList testSet);
  fromList = assertEqual testSet (set.fromList (set.toList testSet));
  gen = assertEqual (set.gen [ "a" "b" ] id) { a = "a"; b = "b"; };
  without = assertEqual (set.without [ "a" ] { a = 0; b = 1; }) { b = 1; };
  retain = assertEqual (set.retain [ "a" ] { a = 0; b = 1; }) { a = 0; };
  optional = assertEqual (set.optional false { a = 0; }) { };
  get = assertEqual (set.get "a" { a = 0; }) 0;
  getOr = assertEqual (set.getOr 0 "a" {}) 0;
  at = assertEqual (set.at [ "a" "b" ] { a.b = 0; }) 0;
  atOr = assertEqual (set.atOr null [ "a" "b" "c" ] { a.b = 0; }) null;
  lookup = string.unlines [
    (assertEqual (set.lookup "a" { a = 0; }) (optional.just 0))
    (assertEqual (set.lookup "a" { }) optional.nothing)
  ];
  lookupAt = string.unlines [
    (assertEqual (set.lookupAt [ "a" "b" ] { a.b = 0; }) (optional.just 0))
    (assertEqual (set.lookupAt [ "a" "c" ] { a.b = 0; }) optional.nothing)
  ];
}
