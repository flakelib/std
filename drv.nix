{ lib }: let
  inherit (lib) Str Path Ty Nix Drv;
in {
  isPath = p: Str.hasPrefix Nix.storeDir p;

  nameWithPath = p:
    Str.substring 33 (-1) (Path.baseName p);

  nameOf = d:
    if Ty.drv.check d then d.name
    else if Drv.isPath d then (Drv.nameWithPath d)
    else throw "unknown program ${Ty.show d}";

  parsedNameOf = d: builtins.parseDrvName (Drv.nameOf d);

  # program name as defined by `nix run`
  mainProgramName = d: d.meta.mainProgram or d.pname or (Drv.parsedNameOf d).name;

  # absolute path to a derivation's `mainProgramName`
  mainProgram = d: "${d.bin or d}/bin/${Drv.mainProgramName d}";
}
