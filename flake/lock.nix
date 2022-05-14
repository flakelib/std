{ lib }: let
  inherit (lib) Flake Rec Set Ty;
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
  fn.rootNode = lock: Lock.Node.New lock.nodes.${lock.root};
  fn.nodes = lock: Set.map (_: Lock.Node.New) lock.nodes;
  # TODO: version check 5~7
} // {
  New = Lock.TypeId.new;
  ReadFile = path: builtins.fromJSON (builtins.readFile path);

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
    };
    fn.sourceInfo = node: node.locked or node.original;
  } // {
    New = Lock.Node.TypeId.new;
  };
}
