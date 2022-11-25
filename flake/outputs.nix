{ lib }: let
  inherit (lib) Flake Set;
  inherit (Flake) Outputs;
in {
  StaticAttrs = [ "lib" "overlays" "overlay" "nixosModules" "nixosModule" "nixosConfigurations" "templates" "defaultTemplate" ];
  NativeAttrs = Outputs.NativePackageAttrs ++ Outputs.NativePackageSetAttrs;
  NativePackageAttrs = [ "defaultPackage" "defaultApp" "devShell" "defaultBundler" ];
  NativePackageSetAttrs = [
    "packages" "legacyPackages"
    "devShells"
    "checks"
    "apps"
    "bundlers"
  ];

  # WrapOverlay :: overlay -> overlay
  # fixes overlays to help a flake pass the `nix flake check` command's strict requirements
  WrapOverlay = overlay: let
    # NOTE: if nix ever gets less picky, consider using builtins.nixVersion here
    overlay' = if builtins.isPath overlay
      then import overlay
      else overlay;
  in final: prev: overlay' final prev;

  # description :: Outputs -> Optional string
  description = Set.lookup "description";

  isAvailable = f: (builtins.tryEval (f ? sourceInfo)).success;

  staticOutputs = f: Set.without Outputs.NativeAttrs f;

  sourceInfo = f: Flake.Source.New f.sourceInfo;
}
