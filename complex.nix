{ lib }: let
  inherit (lib.Std.std) num;
  inherit (num) complex;
in {
  inherit (complex) conjugate cis;
  Polar = complex.mkPolar;
}
