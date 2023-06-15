{ lib }: let
  inherit (lib) Nix Str Regex Set List Bool Fn Ty;
  inherit (Str) AnsiSGR;
in {
  Seq = builtins.seq;
  SeqDeep = builtins.deepSeq;

  Print = builtins.trace;
  PrintDeep = value: builtins.trace (Nix.SeqDeep value);
  Warn = msg: Nix.Print (AnsiSGR.wrap [ AnsiSGR.Red AnsiSGR.Bold ] "WARN: ${msg}");
  WarnIf = cond: msg: value: Bool.Iif cond (Nix.Warn msg value) value;
  Info = msg: Nix.Print "${AnsiSGR.wrap [ AnsiSGR.Blue ] "INFO:"} ${msg}";
  TODO = msg: Nix.Print "${AnsiSGR.wrap [ AnsiSGR.Cyan AnsiSGR.Bold ] "TODO:"} ${msg}";

  # Trace :: a -> a
  # Prints a (usually shallow) debug view of `a`, then returns it.
  Trace = Nix.TraceMap Fn.id;
  # TraceMap :: f -> a -> a
  # Prints `f a`, then returns the unmodified `a`.
  TraceMap = f: value: Nix.Print (f value) value;

  # Show :: a -> a
  # Prints `Ty.Show a`, then returns `a`.
  Show = Nix.ShowMap Fn.id;
  # ShowMap :: f -> a -> a
  # Prints `Ty.Show (f a)`, then returns `a`.
  ShowMap = f: Nix.TraceMap (v: Ty.Show (f v));

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
  discardContext = builtins.unsafeDiscardStringContext;

  appendContext = let
    contextToString = key: cx: let
      drv = import key;
    in if cx.path or false == true then "${/. + key}"
      else if cx ? outputs then Str.concatMap (Fn.flip Set.unsafeGet drv) cx.outputs
      else throw "unknown context type for ${key}: ${toString (Set.keys cx)}";
    appendContext' = str: context: let
      context' = Set.mapToValues contextToString context;
    in List.foldl' (Fn.flip Nix.addContextFrom) str context';
  in Fn.flip (builtins.appendContext or appendContext');

  # TODO: smuggle data into this using `{ outputs = [ (toJSON xxx) ]; }` as the context data?
  # alternatively: `"${discardContext builtins.toFile json}".path = true`
  setContext = context: str: Nix.appendContext context (Nix.discardContext str);
}
