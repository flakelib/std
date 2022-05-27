{ lib }: let
  inherit (lib) Set Flake;
  inherit (Flake) Lock;
  lock = Lock.LoadDir ./.;
  inherit (Lock.Node.inputs (Lock.root lock)) nixpkgs;
  shells = system: let
    pkgs = nixpkgs.legacyPackages.${system};
    update = pkgs.writeShellScriptBin "std-update" ''
      nix flake update .
      nix flake update ./ci
    '';
  in {
    default = pkgs.mkShell {
      nativeBuildInputs = [ update ];
    };
  };
in Set.gen [
  "x86_64-linux"
] shells
