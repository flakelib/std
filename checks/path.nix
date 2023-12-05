{ lib }: let
  inherit (lib) Assert Path Nix;
  testDrv = builtins.derivation {
    name = "test";
    builder = "test";
    system = "x86_64-linux";
  };
in {
  name = "path";
  assertions = {
    toPath-toString = Assert.Eq {
      exp = ./path.nix;
      val = Path.toPath (toString ./path.nix);
    };
    toPath-path = Assert.Eq {
      exp = ./path.nix;
      val = Path.toPath ./path.nix;
    };
    toPath-storeDir = Assert.Eq {
      exp = /. + (Nix.discardContext testDrv.outPath);
      val = Path.toPath testDrv;
    };
  };
}
