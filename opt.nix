{ lib }: let
  inherit (lib) Opt Bool Fn Ty;
in {
  inherit (Opt.functor) map;

  default = d: Fn.flip Opt.match {
    just = Fn.id;
    nothing = d;
  };

  Iif = Bool.toOptional;

  Of = Ty.optOf;
}
