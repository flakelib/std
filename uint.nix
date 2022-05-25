{ lib }: let
  inherit (lib) Opt List Set Str UInt;
  inherit (lib.Std.std) num;
  inherit (num) bits;
in {
  inherit (bits)
    bitSize bit set clear toggle test
    rotateL rotateR
    popCount countTrailingZeros countLeadingZeros;
  and = bits.bitAnd;
  or' = bits.bitOr;
  xor = bits.bitXor;
  not = bits.bitNot;
  shiftL = bits.shiftLU;
  shiftR = bits.shiftRU;
  scanForward = bits.bitScanForward;
  scanReverse = bits.bitScanReverse;

  inherit (num)
    add mul
    negate abs signum min max compare
    quot rem div mod
    quotRem divMod
    even odd
    fac pow gcd lcm clamp
    toBaseDigits
    toFloat;
  toHex = num.toHexString;
  inherit (builtins) sub;
  FromBaseDigits = num.fromBaseDigits;
  TryParse = x: let
    i = x num.tryParseInt x;
  in Opt.match (num.tryParseInt x) {
    inherit (Opt) nothing;
    just = i: Opt.Iif (i >= 0) i;
  };
  Parse = x: let
    i = num.parseInt x;
  in if i < 0
    then throw "std.UInt.Parse: ${toString i} is negative"
    else i;
  Max = num.maxInt;
  Min = 0;

  toHexUpper = v: Str.toUpper (UInt.toHex v);
  toHexLower = UInt.toHex;
  FromHex = s: UInt.FromBaseDigits 16 (List.map UInt.FromHexDigit (Str.toChars s));

  HexChars = "0123456789abcdef";
  FromHexDigit = let
    charsFor = str: List.imap (i: c: { _0 = c; _1 = i; }) (Str.toChars str);
    chars = Set.fromList (charsFor UInt.HexChars ++ charsFor (Str.toUpper UInt.HexChars));
  in d: chars.${d};
}
