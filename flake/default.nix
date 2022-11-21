{ lib }: let
  inherit (lib) Flake Set List Fix Opt Serde;
in {
  description = Set.lookup "description";
  outputsFn = flake: flake.outputs;

  # CallDir :: Flake -> set -> Flake.Outputs
  call = flake: inputs: Fix.fix (self: flake.outputs ({
    inherit self;
  } // inputs));

  # CallDir :: path -> set -> Flake.Outputs
  CallDir = path: inputs: Fix.fix (self: {
    outPath = path;
  } // (import (path + "/flake.nix")).outputs ({
    inherit self;
  } // inputs));

  # LoadDir :: path -> Flake.Outputs
  LoadDir = let
    lock = Flake.Lock.ReadFile ../ci/flake.lock;
    inputs = {
      flake-compat = Flake.Source.fetch (Flake.Lock.Node.sourceInfo (Flake.Lock.nodes lock).flake-compat);
      nixpkgs = throw "nixpkgs";
    };
    inherit ((Flake.call (import ../ci/flake.nix) inputs).lib) loadFlake;
  in {
    inherit (inputs) flake-compat;
    compat = src: loadFlake { inherit src; };
    locked = src: Flake.Lock.outputs (Flake.Lock.LoadDir src);
    __functor = self: self.compat;
  };

  LoadWith =
  { sources ? { }
  , lockData ? Serde.ReadJSON (path + "/flake.lock")
  , path
  , defaultPackage ? "default"
  , nixpkgsAttr ? Opt.toNullable (List.find (k: List.elem k [ "nixpkgs" "pkgs" ]) (
      Set.keys lockData.nodes.${lockData.root}.inputs or { })
    )
  , pkgs ? null
  , system ? pkgs.system or null
  }: let
    inherit (Flake) Lock;
    lock = Lock.New (lockData // {
      override.sources = {
        ${lockData.root} = toString path;
        ${nixpkgsAttr} =
          if pkgs ? path then toString pkgs.path else null;
      } // sources;
    });
    outputs = Lock.outputs lock;
    systemAttrNames = [
      "packages" "legacyPackages" "devShells" "apps" "checks"
    ];
    systemAttrs = Set.map (_: p: p // p.${system} or { }) (Set.retain systemAttrNames outputs) // Set.optional (nixpkgsAttr != null) {
      pkgs = outputs.inputs.${nixpkgsAttr}.legacyPackages.${system};
    };
  in Set.optional (defaultPackage != null && system != null) systemAttrs.packages.${defaultPackage} or { }
  // outputs
  // Set.optional (system != null) systemAttrs;

  Source = import ./source.nix { inherit lib; };
  Outputs = import ./outputs.nix { inherit lib; };
  Lock = import ./lock.nix { inherit lib; };
  App = import ./app.nix { inherit lib; };
}
