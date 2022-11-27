{ lib }: let
  inherit (lib) Flake Set List Fix Opt Null Serde;
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
  , enableInputsSelf ? false
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
  // Set.without (List.optional (defaultPackage != null) "outputs") outputs
  // Set.optional enableInputsSelf {
    inputs = outputs.inputs // {
      self = outputs;
    };
  } // Set.optional (system != null) systemAttrs;

  Bootstrap =
  { path
  , lockData ? Serde.ReadJSON (path + "/flake.lock")
  , enableSystem ? true
  , enablePkgs ? true
  , defaultSystem ? builtins.currentSystem or null
  , defaultPkgs ? (import <nixpkgs> { })
  , loadWith ? { }
  , fn ? { outputs, ... }: outputs
  }@args: let
    load = {
      inherit lockData path;
      ${if enablePkgs then null else "nixpkgsAttr"} = null;
      enableInputsSelf = true;
    } // loadWith;
    tryPkgs = let
      try = (builtins.tryEval defaultPkgs);
    in if try.success then try.value else null;
    f = {
      pkgs ? tryPkgs
    , system ? pkgs.system or defaultSystem
    , ...
    }@args: fn ({
      outputs = Flake.LoadWith ({
        pkgs = Null.Iif enablePkgs pkgs;
        system =
          if !enableSystem then null
          else if args ? system then system
          else if args ? pkgs then pkgs.system or defaultSystem
          else defaultSystem;
      } // load);
    } // args);
    outputs = Flake.LoadWith load;
  in {
    inherit outputs;
    inherit (outputs) sourceInfo outPath;
    inputs = outputs.inputs // {
      self = outputs;
    };
    __functor = self:
      if enableSystem || enablePkgs || args ? fn then f
      else { ... }@args: fn ({ inherit outputs; } // args);
  };


  Source = import ./source.nix { inherit lib; };
  Outputs = import ./outputs.nix { inherit lib; };
  Lock = import ./lock.nix { inherit lib; };
  App = import ./app.nix { inherit lib; };
}
