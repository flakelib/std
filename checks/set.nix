{ lib }: let
  inherit (lib) Assert Set Opt Str Fn Ty;
  testSet = { a = 0; b = 1; c = 2; };
in {
  name = "set";
  assertions = {
    get = Assert.Eq {
      exp = 0;
      val = Set.get "a" { a = 0; };
    };
    getOr = Assert.Eq {
      exp = 0;
      val = Set.getOr 0 "a" {};
    };
    at = Assert.Eq {
      exp = 0;
      val = Set.at [ "a" "b" ] { a.b = 0; };
    };
    atOr = Assert.Eq {
      exp = null;
      val = Set.atOr null [ "a" "b" "c" ] { a.b = 0; };
    };
    lookup = Assert.Eq {
      exp = Opt.just 0;
      val = Set.lookup "a" { a = 0; };
    };
    lookup-nothing = Assert.Eq {
      exp = Opt.nothing;
      val = Set.lookup "a" { };
    };
    lookupAt = Assert.Eq {
      exp = Opt.just 0;
      val = Set.lookupAt [ "a" "b" ] { a.b = 0; };
    };
    lookupAt-nothing = Assert.Eq {
      exp = Opt.nothing;
      val = Set.lookupAt [ "a" "c" ] { a.b = 0; };
    };
    merge = Assert.Eq {
      exp = testSet // { a = testSet; };
      val = Set.merge [ { a = testSet; } testSet ];
    };
    merge-recursive = Assert.Eq {
      exp = { a.x = testSet; a.y = testSet; };
      val = Set.merge [ { a.x = testSet; } { a.y = testSet; } ];
    };
    merge-empty = Assert.Eq {
      exp = { };
      val = Set.merge [ {} {} ];
    };
    merge-nothing = Assert.Eq {
      exp = { };
      val = Set.merge [ ];
    };
    merge-id = Assert.Eq {
      exp = testSet;
      val = Set.merge [ testSet ];
    };
    merge-prio = Assert.Eq {
      exp = testSet;
      val = Set.merge [ testSet { a = testSet; } ];
    };
    merge-map = let
      set = Set.mergeWith {
        mapToSet = path: v: if Ty.function.check v then Opt.just (Fn.toSet v)
          else if Ty.string.check v then Opt.just (Str.toSet v)
          else if Ty.attrs.check v then Opt.just v
          else Opt.nothing;
        sets = [ { a.x = "hi"; a.y = Fn.id; } { a.x.a = 0; a.y.a = 0; } ];
      };
    in Assert.All [
      (Assert.Eq {
        exp = "hi";
        val = Str set.a.x;
      })
      (Assert.Eq {
        exp = 0;
        val = set.a.x.a;
      })
      (Assert.Eq {
        exp = 0;
        val = set.a.y set.a.y.a;
      })
    ];
  };
}
