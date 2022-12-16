{
  inputs = {
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-22.11";
    };
  };
  outputs = { self, flake-compat, nixpkgs }: {
    lib = {
      loadFlake = { src, system ? "unknown-system", ... }@args: (import flake-compat args).defaultNix;
      std = import ../default.nix;
    };
  };
}
