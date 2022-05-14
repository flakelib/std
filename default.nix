let
  lock = builtins.fromJSON (builtins.readFile ./flake.lock);
  sourceInfo = lock.nodes.nix-std.locked;
  nix-std = fetchTarball {
    url = "https://github.com/${sourceInfo.owner}/${sourceInfo.repo}/archive/${sourceInfo.rev}.tar.gz";
    sha256 = sourceInfo.narHash;
  };
  std = import nix-std;
  lib = import ./lib.nix {
    inherit lib std;
  };
in lib
