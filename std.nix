{ lib }: let
  inherit (lib) Std Set;
  inherit (Std) compatNames compatNamesNew;
in {
  inherit (Std.std) version;
  inherit lib;

  compat = Set.map (_: newName: lib.${newName}) (compatNames // compatNamesNew) // {
    num = lib.Int // lib.UInt // lib.Float // Std.std.num;
  };
  compatNames = {
    bool = "Bool";
    function = "Fn";
    list = "List";
    nonempty = "NonEmpty";
    nullable = "Null";
    optional = "Opt";
    path = "Path";
    set = "Set";
    string = "Str";
    num = [ "Int" "UInt" "Float" ];

    fixpoints = "Fix";
    types = "Ty";
    regex = "Regex";
    serde = "Serde";

    applicative = "Applicative";
    functor = "Functor";
    monad = "Monad";
    monoid = "Monoid";
    semigroup = "Semigroup";
  };
  # new modules that don't exist upstream
  compatNamesNew = {
    drv = "Drv";
    flake = "Flake";
    int = "Int";
    uInt = "UInt";
    float = "Float";
    complex = "Complex";
    system = "System";
    assertion = "Assert";
    cmp = "Cmp";
    record = "Rec";
    enum = "Enum";
    nix = "Nix";
  };
}
