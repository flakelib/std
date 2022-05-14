{
  inputs = {
    nix-std.url = "github:flakelib/std/master";
  };
  outputs = { self, nix-std, ... }: {
    lib = import ./lib.nix {
      inherit (self) lib;
      std = nix-std.lib;
    };
    checks = let
      checks = import ./checks { inherit (self) lib; };
    in if checks.ok then { } else throw checks.output.failures;
  };
}
