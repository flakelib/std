{ lib }: let
  inherit (lib.Std.std) string;
  inherit (lib) Str List Ty Nix Regex;
in {
  # backcompat
  index = string.unsafeIndex;
  head = string.unsafeHead;
  tail = string.unsafeTail;
  init = string.unsafeInit;
  last = string.unsafeLast;

  From = toString;

  __functor = Str: Str.From;

  toSet = str:  { __toString = _: str; };

  raw = Nix.discardContext;

  splitOn = delim: Regex.splitOn (Regex.escape delim);
  split = Str.splitOn;

  is = x: List.elem (Ty.primitiveNameOf x) [ "path" "string" "null" "int" "float" "bool" ]
    || (Ty.list.check x && List.all Str.is x)
    || x ? outPath
    || x ? __toString;

  OfPattern = Ty.stringMatching;

  CSI = "[";

  # ansiSGR :: int | string | [int | string] -> AnsiSGR
  # ANSI Select Graphic Rendition
  AnsiSGR = let
    inherit (lib) Set;
    inherit (Str) AnsiSGR;
    named = {
      Reset = 0;
      ResetFg = 39;
      ResetBg = 49;
      Bold = 1;
      BoldOff = 22;
      Underline = 4;
      UnderlineOff = 24;
      Blink = 5;
      BlinkOff = 25;
      Negative = 7;
      NegativeOff = 27;
      Invisible = 8;
      InvisibleOff = 28;
      Black = 30;
      BlackBg = 40;
      BlackBright = 90;
      BlackBgBright = 100;
      Red = 31;
      RedBg = 41;
      RedBright = 91;
      RedBrightBg = 101;
      Green = 32;
      GreenBg = 42;
      GreenBright = 92;
      GreenBrightBg = 102;
      Yellow = 33;
      YellowBg = 43;
      YellowBright = 93;
      YellowBrightBg = 103;
      Blue = 34;
      BlueBg = 44;
      BlueBright = 94;
      BlueBrightBg = 104;
      Purple = 35;
      PurpleBg = 45;
      PurpleBright = 95;
      PurpleBrightBg = 105;
      Cyan = 36;
      CyanBg = 46;
      CyanBright = 96;
      CyanBrightBg = 106;
      White = 37;
      WhiteBg = 47;
      WhiteBright = 97;
      WhiteBrightBg = 107;
    };
  in Set.map (AnsiSGR.NamedParam) named // {

    NamedParam = name: param: {
      inherit name param;

      __toString = self: toString self.param;
    };

    Param = v:
      if v ? param then v
      else if builtins.isInt v then AnsiSGR.NamedParam null v
      else AnsiSGR."${v}" or (throw "unsupported SGR attr: ${v}");

    From = sgr:
      if AnsiSGR.TypeId.ty.check sgr then sgr
      else AnsiSGR.New { params = sgr; };

    __functor = _: AnsiSGR.From;

    # csi :: AnsiSGR -> string
    csi = sgr: "${Str.CSI}${Str.concatSep ";" (AnsiSGR sgr).params}m";

    # wrap :: AnsiSGR -> string -> string
    wrap = sgr: str: "${AnsiSGR.csi sgr}${str}${AnsiSGR.csi AnsiSGR.Reset}";

    New = {
      params
    }: AnsiSGR.TypeId.new {
      params = List.map AnsiSGR.Param (List.From params);
    };

    TypeId = Ty.TypeId.new {
      ty = Ty.mkType {
        name = "std:Str.AnsiSGR";
        description = "ANSI Select Graphic Rendition";
        check = x: toString x.type or null == AnsiSGR.TypeId.name;
      };
      new = { params }: {
        ${Ty.TypeId.Attr} = AnsiSGR.TypeId;
        inherit params;
        __toString = AnsiSGR.csi;
      };
    };
  };
}
