{ lib }: let
  inherit (lib) Str Path;
in {
  baseName = p: builtins.baseNameOf (builtins.unsafeDiscardStringContext (toString p));

  dirName = p: let
    p' = if builtins.isString p then builtins.unsafeDiscardStringContext p else Path.toPath p;
  in builtins.dirOf p';

  toPath = p: let
    s = builtins.unsafeDiscardStringContext (toString p);
  in
    if builtins.isPath p then p
    else if Str.hasPrefix "/" s then /. + s
    else throw "relative path";
}
