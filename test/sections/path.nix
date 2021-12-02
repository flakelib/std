with { std = import ./../../default.nix; };
with std;

with (import ./../framework.nix);

let
  testDrv = builtins.derivation {
    name = "test";
    builder = "test";
    system = "x86_64-linux";
  };
in section "std.path" {
  baseName = string.unlines [
    (assertEqual "path.nix" (path.baseName ./path.nix))
    (assertEqual "path.nix" (path.baseName (toString ./path.nix)))
    (assertEqual "-test" (string.substring 32 (-1) (path.baseName testDrv)))
  ];
  dirName = string.unlines [
    (assertEqual ./. (path.dirName ./path.nix))
    (assertEqual (toString ./.) (path.dirName (toString ./path.nix)))
    (assertEqual (path.toPath builtins.storeDir) (path.dirName testDrv))
  ];
}
