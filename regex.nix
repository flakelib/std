{ lib }: let
  inherit (lib) Regex Rec List Bool Null Ty;
  inherit (Regex) Splits;
in {
  splitExt = Splits.Split;

  Splits = Rec.Def {
    name = "std:Regex.Splits";
    fields = {
      split.type = Ty.list;
      count.type = Ty.int;
      prefix.type = Ty.string;
      splits.type = Ty.listOf Splits.SplitSegment.TypeId.ty;
      hasSplits.type = Ty.bool;
      suffix.type = Ty.nullOr Ty.string;
      strings.type = Ty.listOf Ty.string;
    };
    # suffix :: Splits -> Optional string
    fn.suffix = splits: Null.toOptional splits.suffix;
  } // {
    Parse = split: let
      len = List.length split;
      count = len / 2;
      prefix = List.index split 0;
      splits = List.generate (i: let
        captures = List.index split (1 + i * 2);
        suffix = List.index split (2 + i * 2);
      in Splits.SplitSegment.New {
        inherit suffix captures;
      }) count;
      hasSplits = len != 1;
    in Splits.TypeId.new {
      inherit split count prefix splits hasSplits;
      suffix = Bool.toNullable hasSplits (List.last split);
      strings = [ prefix ] ++ map ({ suffix, ... }: suffix) splits;
    };

    Split = p: s: Splits.Parse (Regex.split p s);
    __functor = Splits: Splits.Split;

    SplitSegment = Rec.Def {
      name = "std:Regex.Splits.SplitSegment";
      fields = {
        suffix.type = Ty.string;
        captures.type = Ty.listOf Ty.string;
      };
    } // {
      New = { suffix, captures }@args: Splits.SplitSegment.TypeId.new args;
    };
  };
}
