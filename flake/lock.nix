{ lib }: let
  inherit (lib) Flake Rec Null Bool Opt Str Fn Set List Ty;
  inherit (Flake) Lock;
in Rec.Def {
  name = "std:Flake.Lock";
  Self = Lock;
  fields = {
    version.type = Ty.int;
    root.type = Ty.string;
    nodes.type = Ty.attrsOf Lock.Node.Type;
    #inputs.optional = true; # version 4?
  };
  coerce = {
    ${Ty.string.name} = Lock.ReadFile;
    ${Ty.path.name} = Lock.ReadFile;
    ${Ty.attrs.name} = Lock.New;
  };

  fn.root = lock: (Lock.nodes lock).${lock.root};
  fn.outputs = lock: (Lock.load lock).${lock.root};

  fn.nodes.fn = lock: Set.map (name: node: Lock.Node.New (node // { inherit name lock; })) lock.nodes;
  fn.nodes.memoize = true;

  fn.sources = lock: Set.map (name: node: Null.match lock.override.sources.${name} or null {
    just = Fn.id;
    nothing = Opt.match (Lock.Node.fetch node) {
      just = Fn.id;
      nothing = throw "Flake.Lock.sources: no source for input ${name}";
    };
  }) (Lock.nodes lock);

  fn.sourceInfo.fn = lock: let
    srcs = Lock.sources lock;
  in Set.map (name: node: Null.default { } (Lock.Node.sourceInfo node) // {
    outPath = srcs.${name};
    ${Null.Iif (node ? locked.lastModified) "lastModifiedDate"} = Flake.Source.lastModifiedDate node.locked;
  }) (Lock.nodes lock);
  fn.sourceInfo.memoize = true;

  fn.load.fn = lock: Set.map (_: Lock.Node.load) (Lock.nodes lock);
  fn.load.memoize = true;
  # TODO: version check 5~7
} // {
  New = Lock.TypeId.new;
  LoadDir = path: let
    data = Lock.ReadFile (path + "/flake.lock");
  in Lock.New (data // {
    override.sources.${data.root} = toString path;
  });

  ReadFile = path: Lock.New (builtins.fromJSON (builtins.readFile path));

  Node = Rec.Def {
    name = "std:Flake.Lock.Node";
    Self = Lock.Node;
    fields = {
      flake = {
        type = Ty.bool;
        optional = true;
        default = true;
      };
      locked = {
        type = Flake.Source.Type;
        optional = true;
      };
      original = {
        type = Flake.Source.Type;
        optional = true;
      };
      inputs = {
        type = Ty.attrsOf (Ty.either (Ty.listOf Ty.string) Ty.string);
        optional = true;
      };
      lock.type = Lock.TypeId.ty;
      name.type = Ty.string;
    };

    # sourceInfo :: Flake.Lock.Node -> Nullable Flake.Source
    fn.sourceInfo = node: node.locked or node.original or null;

    # fetch :: Flake.Lock.Node -> Optional
    fn.fetch.fn = node: Opt.map Flake.Source.fetch (Opt.fromNullable (Lock.Node.sourceInfo node));
    fn.fetch.memoize = true;

    fn.inputNames.fn = let
      forInput = lock: spec: if Ty.string.check spec then spec else search lock lock.root spec;
      search = lock: node: spec: if spec == [ ] then node else search lock (Lock.Node.inputNames (Lock.nodes lock).${node}).${List.head spec} (List.tail spec);
    in node: Set.map (_: forInput node.lock) node.inputs or { };
    fn.inputNames.memoize = true;

    fn.inputs.fn = node: Set.map (_: Fn.flip Set.get (Lock.load node.lock)) (Lock.Node.inputNames node);
    fn.inputs.memoize = true;
    fn.outputs.fn = node: Flake.CallDir (Lock.sourceInfo node.lock).${node.name} (Lock.Node.inputs node);
    fn.outputs.memoize = true;
    fn.load = node: let
      sourceInfo = (Lock.sourceInfo node.lock).${node.name};
      outputs = Lock.Node.outputs node;
      inputs = Lock.Node.inputs node;
    in sourceInfo // Set.optional node.flake or true ({ inherit sourceInfo inputs outputs; } // outputs);
  } // {
    New = Lock.Node.TypeId.new;
  };
}
