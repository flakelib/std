with rec {
  string = import ./string.nix;
  regex = import ./regex.nix;
  list = import ./list.nix;
};

rec {
  loadFlake = throw "TODO";

  tupleToPair = { _0, _1 }: { name = _0; value = _1; };

  readFile = file: string.removeSuffix "\n" (builtins.readFile file);

  /* readDrv :: drvPath -> { inputDrvs }

    get all input context/dependencies for a derivation

    not a real parser (yet?)
  */
  readDrv = d: let
    contents = readFile d;
    # https://github.com/NixOS/nix/issues/1245#issuecomment-401642781
    storeBaseRe = "[0-9a-df-np-sv-z]{32}-[+_?=a-zA-Z0-9-][+_?=.a-zA-Z0-9-]*";
    re = "${regex.escape builtins.storeDir}/${storeBaseRe}\\.drv";
  in {
    inputDrvs = regex.allMatches re contents;
  };

  inputsOf = let
    f = inputs: d: list.foldl' (inputs: d:
      if list.elem drv inputs then inputs
      else f (inputs ++ list.singleton d) (readDrv d).inputDrvs
    ) inputs d;
  in d: f list.empty (list.singleton d);

  addContextFrom = context: str: string.substring 0 0 context + str;

  getContext = builtins.getContext;

  setContext = context: str: let
    str' = builtins.unsafeDiscardStringContext str;
  in list.foldl' (str: cx: addContextFrom "${import cs}" str) str' (set.keys context); # TODO: preserve context outputs
}
