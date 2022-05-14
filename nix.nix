{ lib }: let
  inherit (lib) Str Regex Set List Nix;
in {
  inherit (builtins) storeDir;

  tupleToPair = { _0, _1 }: { name = _0; value = _1; };

  readFile = file: Str.removeSuffix "\n" (builtins.readFile file);

  /* readDrv :: drvPath -> { inputDrvs }

    get all input context/dependencies for a derivation

    not a real parser (yet?)
  */
  readDrv = d: let
    contents = Nix.readFile d;
    # https://github.com/NixOS/nix/issues/1245#issuecomment-401642781
    storeBaseRe = "[0-9a-df-np-sv-z]{32}-[+_?=a-zA-Z0-9-][+_?=.a-zA-Z0-9-]*";
    re = "${Regex.escape builtins.storeDir}/${storeBaseRe}\\.drv";
  in {
    inputDrvs = Regex.allMatches re contents;
  };

  inputsOf = let
    f = inputs: d: List.foldl' (inputs: d:
      if List.elem d inputs then inputs
      else f (inputs ++ List.singleton d) (Nix.readDrv d).inputDrvs
    ) inputs d;
  in d: f List.nil [ d ];

  addContextFrom = context: str: Str.substring 0 0 context + str;

  getContext = builtins.getContext;

  setContext = context: str: let
    str' = builtins.unsafeDiscardStringContext str;
    # TODO: builtins.appendContext exists for this
    # TODO: smuggle data into this using `{ outputs = [ (toJSON xxx) ]; }` as the context data
  in List.foldl' (str: cx: Nix.addContextFrom "${import cx}" str) str' (Set.keys context); # TODO: preserve context outputs
}
