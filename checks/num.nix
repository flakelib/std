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
    timestamp = Assert.Eq {
      exp =  { y = 2022; m = 5; d = 27; doy = 87; hours = 17; minutes = 59; seconds = 14; };
      val = UInt.parseTimestamp 1653674354;
    };
  };
}
