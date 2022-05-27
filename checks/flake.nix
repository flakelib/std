{ lib }: let
  inherit (lib) Assert Flake Str Set Fn;
  inherit (Flake) Lock;
  src = builtins.filterSource (path: type: Str.hasPrefix "flake." (baseNameOf path)) ../ci;
  lock = Lock.LoadDir "${src}";
  inputs = {
    inherit (Flake.LoadDir) flake-compat;
    nixpkgs = throw "nixpkgs";
  };
  flake = Flake.CallDir src inputs;
  called = flake.lib.loadFlake { inherit src; };
  loaded = Flake.LoadDir src;
  locked = Lock.outputs lock;
in {
  name = "flake";
  assertions = {
    call = Assert.Eq {
      exp = "${src}";
      val = "${flake}";
    };
    call-fn = Assert.Eq {
      exp = Fn.args (import inputs.flake-compat);
      val = Fn.args flake.lib.loadFlake;
    };
    compat-fn = Assert.Eq {
      exp = Fn.args (import inputs.flake-compat);
      val = Fn.args called.lib.loadFlake;
    };
    load-fn = Assert.Eq {
      exp = Fn.args (import inputs.flake-compat);
      val = Fn.args loaded.lib.loadFlake;
    };
    lock-fn = Assert.Eq {
      exp = Fn.args (import inputs.flake-compat);
      val = Fn.args locked.lib.loadFlake;
    };
  };
}
