let
  lock = builtins.fromJSON (builtins.readFile ../flake.lock);
  sourceInfo = lock.nodes.nix-std.locked;
  nix-std = fetchTarball {
    url = "https://github.com/${sourceInfo.owner}/${sourceInfo.repo}/archive/${sourceInfo.rev}.tar.gz";
    sha256 = sourceInfo.narHash;
  };
  std = import nix-std;
  lib = import ../lib.nix {
    inherit lib std;
    sourceInfo.outPath = ./.;
  };
in {
  inherit std lib;
  outputs = lib.Flake.CallDir (toString ../.) {
    nix-std = lib.Flake.CallDir nix-std { };
  };
}
