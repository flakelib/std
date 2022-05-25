{ lib }: let
  inherit (lib) Str Path Ty Null Nix Drv;
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

  appendPassthru = passthru: d: d // passthru; # TODO: nixpkgs.lib.extendDerivation also modifies outputs

  # derivations that can reference their own (potentially overridden) attributes
  Fix = fn: let
    drv = fn drv;
    passthru = {
      ${Null.Iif (drv ? override) "override"} = f: Drv.Fix (drv: (fn drv).override f);
      ${Null.Iif (drv ? overrideDerivation) "overrideDerivation"} = f: Drv.Fix (drv: (fn drv).overrideDerivation f);
      ${Null.Iif (drv ? overrideAttrs) "overrideAttrs"} = f: Drv.Fix (drv: (fn drv).overrideAttrs f);
    };
  in Drv.appendPassthru passthru drv;

  # add persistent passthru attributes that can refer to the derivation
  fixPassthru = fn: drv: if Ty.function.check drv # allow chaining with mkDerivation
    then attrs: Drv.fixPassthru fn (drv attrs)
    else Drv.Fix (dself: drv.overrideAttrs (old: { passthru = old.passthru or {} // fn dself; }));
}
