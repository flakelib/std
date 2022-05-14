{ lib }: let
  inherit (lib) Null Bool Ty;
in {
  inherit (Null.functor) map;

  Iif = Bool.toNullable;

  Of = Ty.nullOr;
}
