{ lib }: let
  inherit (lib) Str Path Nix;
in {
  baseName = p: builtins.baseNameOf (Nix.discardContext (toString p));

  dirName = p: let
    p' = if builtins.isString p then Nix.discardContext p else Path.toPath p;
  in builtins.dirOf p';

  toPath = p: let
    s = Nix.discardContext (toString p);
  in
    if builtins.isPath p then p
    else if Str.hasPrefix "/" s then /. + s
    else throw "relative path";
}
