{ lib }: let
  inherit (lib) Flake Set Fix;
in {
  description = Set.lookup "description";
  outputsFn = flake: flake.outputs;

  # CallDir :: Flake -> set -> FlakeInput
  call = flake: inputs: Fix.fix (self: flake.outputs ({
    inherit self;
  } // inputs));

  # CallDir :: path -> set -> FlakeInput
  CallDir = path: inputs: Fix.fix (self: {
    outPath = path;
  } // (import (path + "/flake.nix")).outputs ({
    inherit self;
  } // inputs));

  LoadDir = let
    lock = Flake.Lock.ReadFile ./flake.lock;
    inputs = {
      flake-compat = Flake.Source.fetch (Flake.Lock.Node.sourceInfo (Flake.Lock.nodes lock).flake-compat);
    };
    inherit ((Flake.call (import ./flake.nix) inputs).lib) loadFlake;
  in {
    inherit (inputs) flake-compat;
    __functor = _: src: loadFlake { inherit src; };
  };

  Source = import ./source.nix { inherit lib; };
  Outputs = import ./outputs.nix { inherit lib; };
  Lock = import ./lock.nix { inherit lib; };
  App = import ./app.nix { inherit lib; };
}
