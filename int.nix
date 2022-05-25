{ lib }: let
  inherit (lib.Std.std) num;
  inherit (num) bits;
in {
  inherit (bits)
    bitSize bit set clear toggle test
    shiftL shiftR rotateL rotateR
    popCount countTrailingZeros countLeadingZeros;
  and = bits.bitAnd;
  or' = bits.bitOr;
  xor = bits.bitXor;
  not = bits.bitNot;
  scanForward = bits.bitScanForward;
  scanReverse = bits.bitScanReverse;

  inherit (num)
    add mul
    negate abs signum min max compare
    quot rem div mod
    quotRem divMod
    even odd
    fac pow gcd lcm clamp
    toFloat;
  inherit (builtins) sub;
  FromBaseDigits = num.fromBaseDigits;
  TryParse = num.tryParseInt;
  Parse = num.parseInt;
  Max = num.maxInt;
  Min = num.minInt;
}
