{ lib }: let
  inherit (lib.Std.std) num;
in {
  inherit (num)
    add mul
    negate abs signum min max compare
    quot pow
    sin cos
    truncate floor ceil round
    clamp;
  inherit (builtins) div sub;
  Pi = num.pi;
  TryParse = num.tryParseFloat;
  Parse = num.parseFloat;
}
