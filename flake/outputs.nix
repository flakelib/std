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

  # description :: Outputs -> Optional string
  description = Set.lookup "description";

  isAvailable = f: (builtins.tryEval (f ? sourceInfo)).success;

  staticOutputs = f: Set.without Outputs.NativeAttrs f;

  sourceInfo = f: Flake.Source.New f.sourceInfo;
}
