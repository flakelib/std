{ lib }: let
  inherit (lib) Assert Fn Int;
  testArgs = { a = 0; b = 1; };
  testOverrideFn = { a, b, c ? 1 }: { x = a + b + c; };
in {
  name = "fn";
  assertions = {
    pipe = Assert.Eq {
      exp = 6;
      val = Fn.pipe [ (Int.add 2) (Int.mul 2) ] 1;
    };
    overridable = Assert.Eq {
      exp = 2;
      val = (Fn.overridable testOverrideFn testArgs).x;
    };
    overridable-override-nop = Assert.Eq {
      exp = 2;
      val = ((Fn.overridable testOverrideFn testArgs).override { c = 1; }).x;
    };
    overridable-override = Assert.Eq {
      exp = 3;
      val = ((Fn.overridable testOverrideFn testArgs).override { a = 1; }).x;
    };
    overridable-override-shadow = Assert.Eq {
      exp = 3;
      val = (((Fn.overridable testOverrideFn testArgs).override { a = 2; }).override { a = 1; }).x;
    };
    overridable-override-nested = Assert.Eq {
      exp = 3;
      val = (((Fn.overridable testOverrideFn testArgs).override { c = 1; }).override { a = 1; }).x;
    };
  };
}
