{
  inputs = {
    nix-std.url = "github:chessai/nix-std";
  };
  outputs = { self, nix-std, ... }: {
    lib = import ./lib.nix {
      inherit (self) lib sourceInfo;
      std = nix-std.lib;
    };

    checks = let
      checks = import ./checks { inherit (self) lib; };
    in if checks.ok then { } else throw checks.output.failures;

    devShells = import ./ci/shells.nix { inherit (self) lib; };

    flakes.config = {
      name = "Std";
      lib.namespace = [ ];
    };
  };
}
