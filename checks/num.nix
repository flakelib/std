{ lib }: let
  inherit (lib) Assert UInt;
in {
  name = "num";
  assertions = {
    to-hex = Assert.Eq {
      exp = "1e";
      val = UInt.toHexLower 30;
    };
    to-hex-upper = Assert.Eq {
      exp = "1E";
      val = UInt.toHexUpper 30;
    };
    from-hex = Assert.Eq {
      exp = 30;
      val = UInt.FromHex "1e";
    };
    from-hex-upper = Assert.Eq {
      exp = 30;
      val = UInt.FromHex "1E";
    };
  };
}
