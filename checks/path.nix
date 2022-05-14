{ lib }: let
  inherit (lib) Assert Path Str Ty;
  testDrv = builtins.derivation {
    name = "test";
    builder = "test";
    system = "x86_64-linux";
  };
in {
  name = "path";
  assertions = {
    baseName = Assert.Eq {
      exp = "path.nix";
      val = Path.baseName ./path.nix;
    };
    baseName-toString = Assert.Eq {
      exp = "path.nix";
      val = Path.baseName (toString ./path.nix);
    };
    baseName-name = Assert.Eq {
      exp = "-test";
      val = Str.substring 32 (-1) (Path.baseName testDrv);
    };
    dirName = Assert.Eq {
      exp = ./.;
      val = Path.dirName ./path.nix;
    };
    dirName-str = Assert.Eq {
      exp = toString ./.;
      val = Path.dirName (toString ./path.nix);
    };
    dirName-storeDir = Assert.Eq {
      exp = Path.toPath builtins.storeDir;
      val = Path.dirName testDrv;
    };
    ty-check = Assert.True {
      val = Ty.path.check ./path.nix;
    };
    ty-check-string = Assert.True {
      val = ! Ty.path.check (toString ./path.nix);
    };
    ty-check-pathlike = Assert.True {
      val = Ty.pathlike.check ./path.nix;
    };
    ty-check-pathlike-string = Assert.True {
      val = Ty.pathlike.check (toString ./path.nix);
    };
    ty-check-pathlike-false = Assert.True {
      val = ! Ty.pathlike.check "a/b/c";
    };
  };
}
