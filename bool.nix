{ lib }: let
  inherit (lib) Bool;
in {
  Iif = Bool.ifThenElse;

  toInt = b: if b then 1 else 0;
}
