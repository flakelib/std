with rec {
  string = import ./string.nix;
  path = import ./path.nix;
  types = import ./types.nix;
};

rec {
  nixStore = builtins.storeDir;

  isPath = p: string.hasPrefix nixStore p;

  nameWithPath = p:
    string.substring 33 (-1) (path.baseName p);

  nameOf = d:
    if types.drv.check d then d.name
    else if isPath d then (nameWithPath d)
    else throw "unknown program ${types.show d}";

  parsedNameOf = d: builtins.parseDrvName (nameOf d);

  # program name as defined by `nix run`
  mainProgramName = d: d.meta.mainProgram or d.pname or (parsedNameOf d).name;

  # absolute path to a derivation's `mainProgramName`
  mainProgram = d: "${d.bin or d}/bin/${mainProgramName d}";
}
