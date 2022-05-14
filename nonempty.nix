{ lib }: let
  inherit (lib) Ty;
in {
  Of = Ty.nonEmptyListOf;
}
