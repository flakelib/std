{ lib }: let
  inherit (lib) Str List Ty;
in {
  From = toString;

  __functor = Str: Str.From;

  toSet = str:  { __toString = _: str; };

  raw = builtins.unsafeDiscardStringContext;

  is = x: List.elem (Ty.primitiveNameOf x) [ "path" "string" "null" "int" "float" "bool" ]
    || (Ty.list.check x && List.all Str.is x)
    || x ? outPath
    || x ? __toString;

  OfPattern = Ty.stringMatching;
}
