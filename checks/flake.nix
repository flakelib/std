{ lib }: let
  inherit (lib) Assert Flake Str Set Fn;
  src = builtins.filterSource (path: type: Str.hasPrefix "flake." (baseNameOf path)) ../flake;
  lock = Flake.Lock.ReadFile "${src}/flake.lock";
  inputs = {
    inherit (Flake.LoadDir) flake-compat;
  };
  flake = Flake.CallDir src inputs;
  called = flake.lib.loadFlake { inherit src; };
  loaded = Flake.LoadDir src;
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
  };
}
