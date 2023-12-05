{ lib }: let
  inherit (lib) Str Path Ty Nix;
in {
  toPath = p: let
    s = Nix.discardContext (toString p);
  in
    if Ty.path.check p then p
    else if Str.hasPrefix "/" s then Path.unsafeFromString s
    else throw "relative path";
}
