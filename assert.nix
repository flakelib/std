{ lib }: let
  inherit (lib)
    Assert Nix
    Set List Str Bool Opt Cmp Fn Ty;
in {
  throwOr = assertion: value: Opt.match (Assert.toOptional assertion value) {
    just = Fn.id;
    nothing = throw (Assert.failedString assertion);
  };

  warn = assertion: value: Opt.match (Assert.failedString assertion) {
    just = Fn.flip Nix.Warn value;
    nothing = value;
  };

  toOptional = assertion: v: Bool.toOptional (Assert.ok assertion) v;

  toString = assertion: Opt.match (Assert.toFailedString assertion) {
    just = Fn.id;
    nothing = Assert.okString assertion;
  };

  toFailedString = assertion: Bool.toOptional (Assert.failed assertion) (Assert.failedString assertion);

  ok = assertion: assertion.eval;
  failed = assertion: ! assertion.eval;

  okString = assertion: "${assertion.name} ok";
  failedString = assertion: "${assertion.name} ${assertion.msg}";

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
