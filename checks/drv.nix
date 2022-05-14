{ lib }: let
  inherit (lib) Assert Drv;
  testDrv = builtins.derivation {
    name = "test";
    builder = "test";
    system = "x86_64-linux";
  };
  testProgram = "${testDrv}/bin/test";
in {
  name = "drv";
  assertions = {
    mainProgram = Assert.Eq {
      exp = testProgram;
      val = Drv.mainProgram testDrv;
    };
    mainProgram-outPath = Assert.Eq {
      exp = testProgram;
      val = Drv.mainProgram testDrv.outPath;
    };
  };
}
