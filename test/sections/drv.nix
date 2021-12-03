with { std = import ./../../default.nix; };
with std;

with (import ./../framework.nix);

let
  testDrv = builtins.derivation {
    name = "test";
    builder = "test";
    system = "x86_64-linux";
  };
  testProgram = "${testDrv}/bin/test";
in section "std.drv" {
  mainProgram = string.unlines [
    (assertEqual testProgram (drv.mainProgram testDrv))
    (assertEqual testProgram (drv.mainProgram testDrv.outPath))
  ];
}
