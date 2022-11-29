{ lib }: let
  inherit (lib) Assert Set List Str Cmp Ty;
in {
  throwOr = assertion: value:
    if assertion.eval then value
    else throw "${assertion.name} ${assertion.msg}";

  toString = assertion:
    if assertion.eval then "${assertion.name} ok"
    else "${assertion.name} ${assertion.msg}";

  ok = assertion: assertion.eval;
  failed = assertion: ! assertion.eval;

  True = { val, ... }@args: Assert.New ({
    eval = val;
  } // Set.without [ "val" ] args);
  False = { val, ... }@args: Assert.New ({
    eval = !val;
  } // Set.without [ "val" ] args);

  Eq = { val, exp, ... }@args: Assert.Compare args;
  Ne = { val, exp, ... }@args: Assert.Compare ({
    cmp = Cmp.ne;
  } // args);

  Compare = {
    cmp ? Cmp.eq
  , val
  , exp
  , ...
  }@args: let
    res = Cmp.Compare exp val;
  in Assert.New ({
    eval = cmp res;
    msg = "failed: ${Ty.Show val} ${Cmp.sign res} ${Ty.Show exp}";
  } // Set.without [ "val" "exp" "cmp" ] args);

  Throws = { val, ... }@args: let
    try = builtins.tryEval val;
  in Assert.New ({
    eval = !try.success;
    msg = "expected failure, got ${Ty.Show try.value}";
  } // Set.without [ "val" ] args);

  All = asserts: Assert.New {
    eval = List.all Assert.ok asserts;
    name = Str.concatMapSep ", " (a: a.name) asserts;
    msg = Str.concatMapSep ", and " (a: a.msg) (List.filter Assert.failed asserts);
  };

  New = {
    eval
  , name ? "assertion"
  , msg ? "failed"
  }: Assert.TypeId.new {
    inherit eval name msg;
  };

  TypeId = Ty.TypeId.new {
    ty = Ty.mkType {
      name = "std:Assert";
      description = "assertion";
      check = x: toString x.type or null == Assert.TypeId.name;
      show = Assert.toString;
    };
    new = { eval, name, msg }: {
      ${Ty.TypeId.Attr} = Assert.TypeId;
      inherit eval name msg;
      __toString = Assert.toString;
    };
  };
}
