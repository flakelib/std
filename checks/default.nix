{ lib ? import ../default.nix }: let
  inherit (lib) Assert Nix Set Str List Fn;
  importCheck = file: (import file { inherit lib; });
  checks = List.map importCheck [
    ./rec.nix
    ./enum.nix
    ./system.nix
    ./flake.nix
    ./fn.nix
    ./path.nix
    ./drv.nix
    ./set.nix
    ./num.nix
  ];
  sectionOk = section: List.all Assert.ok (Set.values section.assertions);
  mapAssertionLine = name: assertion: "\t${name}: ${assertion}";
  sectionLines = section: List.singleton section.name ++ Set.mapToList mapAssertionLine section.assertions;
  lines = List.concatMap sectionLines checks;
  failures = List.filter (Fn.not sectionOk) checks;
  failureLines = section: List.singleton section.name ++ Set.mapToList mapAssertionLine (Set.filter (_: Fn.not Assert.ok) section.assertions);
in Nix.SeqDeep (Set.without [ "Std" ] lib) {
  ok = List.all sectionOk checks;
  output = {
    all = Str.unlines (List.concatMap sectionLines checks);
    failures = Str.unlines (List.concatMap failureLines failures);
  };
}
