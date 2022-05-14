{ lib }: let
  inherit (lib) System Assert;
  system = "x86_64-linux";
  libc = "newlib";
  linux64 = System.New {
    inherit system;
  };
  complex = System.New {
    inherit system libc;
  };
in {
  name = "system";
  assertions = {
    new = Assert.Eq {
      exp = system;
      val = System.double linux64;
    };
    coerce-string = Assert.Eq {
      exp = System.double (System system);
      val = System.double linux64;
    };
    coerce-new = Assert.Eq {
      exp = System.double (System { inherit system; });
      val = System.double linux64;
    };
    coerce-self = Assert.Eq {
      exp = System.double (System linux64);
      val = System.double linux64;
    };
    simple = Assert.Eq {
      exp = true;
      val = System.isSimple linux64;
    };
    serialize-simple = Assert.Eq {
      exp = system;
      val = System.serialize linux64;
    };
    serialize-complex = Assert.Eq {
      exp = { inherit system libc; };
      val = System.serialize complex;
    };
  };
}
