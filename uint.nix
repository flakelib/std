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

  # parseTime :: uint -> Timestamp
  # example: (UInt.parseTimestamp builtins.currentTime).y
  # https://stackoverflow.com/a/42936293
  parseTimestamp = s: let
    z = s / 86400 + 719468;
    era = (if z >= 0 then z else z - 146096) / 146097;
    doe = z - era * 146097;
    yoe = (doe - doe / 1460 + doe / 36524 - doe / 146096) / 365;
    y = yoe + era * 400;
    doy = doe - (365 * yoe + yoe / 4 - yoe / 100);
    mp = (5 * doy + 2) / 153;
    d = doy - (153 * mp + 2) / 5 + 1;
    m = mp + (if mp < 10 then 3 else -9);
    secondsInDay = UInt.rem s 86400;
  in {
    inherit doy d m;
    y = y + (if m <= 2 then 1 else 0);

    hours = secondsInDay / 3600;
    minutes = (UInt.rem secondsInDay 3600) / 60;
    seconds = UInt.rem s 60;
  };
}
