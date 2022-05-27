{ lib }: let
  inherit (lib) Flake Set Fix;
in {
  description = Set.lookup "description";
  outputsFn = flake: flake.outputs;

  # CallDir :: Flake -> set -> Flake.Outputs
  call = flake: inputs: Fix.fix (self: flake.outputs ({
    inherit self;
  } // inputs));

  # CallDir :: path -> set -> Flake.Outputs
  CallDir = path: inputs: Fix.fix (self: {
    outPath = path;
  } // (import (path + "/flake.nix")).outputs ({
    inherit self;
  } // inputs));

  # LoadDir :: path -> Flake.Outputs
  LoadDir = let
    lock = Flake.Lock.ReadFile ../ci/flake.lock;
    inputs = {
      flake-compat = Flake.Source.fetch (Flake.Lock.Node.sourceInfo (Flake.Lock.nodes lock).flake-compat);
      nixpkgs = throw "nixpkgs";
    };
    inherit ((Flake.call (import ../ci/flake.nix) inputs).lib) loadFlake;
  in {
    inherit (inputs) flake-compat;
    compat = src: loadFlake { inherit src; };
    locked = src: Flake.Lock.outputs (Flake.Lock.LoadDir src);
    __functor = self: self.compat;
  };

  Source = import ./source.nix { inherit lib; };
  Outputs = import ./outputs.nix { inherit lib; };
  Lock = import ./lock.nix { inherit lib; };
  App = import ./app.nix { inherit lib; };
}
