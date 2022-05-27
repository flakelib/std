{ lib }: let
  inherit (lib) Null Bool Fn Ty;
in {
  inherit (Null.functor) map;

  default = d: Fn.flip Null.match {
    just = Fn.id;
    nothing = d;
  };

  Iif = Bool.toNullable;

  Of = Ty.nullOr;
}
