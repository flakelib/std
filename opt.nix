{ lib }: let
  inherit (lib) Opt Bool Ty;
in {
  inherit (Opt.functor) map;

  Iif = Bool.toOptional;

  Of = Ty.optOf;
}
