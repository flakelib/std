{ lib, std, sourceInfo }: let
  optSet = cond: attrs: if cond then attrs else { }; # std.set.optional
  inherit (lib) Ty;
  modules = {
    Bool = {
      src = ./bool.nix;
      upstream = std.bool;
      type = Ty.bool;
    };
    Drv = {
      src = ./drv.nix;
      type = Ty.drv;
    };
    Flake = {
      src = ./flake;
      type = Ty.flake;
    };
    Fn = {
      src = ./fn.nix;
      upstream = std.function;
      type = Ty.function;
    };
    List = {
      src = ./list.nix;
      upstream = std.list;
      type = Ty.list;
      typeOf = Ty.listOf;
      attrs = {
        NonEmptyOf = Ty.nonEmptyListOf;
      };
    };
    NonEmpty = {
      src = ./nonempty.nix;
      upstream = std.nonempty;
    };
    Null = {
      src = ./null.nix;
      upstream = std.nullable;
      type = Ty.null;
      typeOf = Ty.nullOr;
    };
    Int = {
      src = ./int.nix;
      type = Ty.int;
    };
    UInt = {
      src = ./uint.nix;
      type = Ty.u32;
    };
    Float = {
      src = ./float.nix;
      type = Ty.float;
    };
    Complex = {
      src = ./complex.nix;
      type = Ty.complex;
    };
    Opt = {
      src = ./opt.nix;
      upstream = std.optional;
      type = Ty.opt;
      typeOf = Ty.optOf;
    };
    Path = {
      src = ./path.nix;
      type = Ty.path;
    };
    Set = {
      src = ./set.nix;
      upstream = std.set;
      type = Ty.attrs;
      typeOf = Ty.attrsOf;
    };
    Str = {
      src = ./str.nix;
      upstream = std.string;
      type = Ty.string;
    };
    System = {
      src = ./system.nix;
      type = Ty.system;
    };
    Ty = {
      src = ./ty.nix;
      upstream = std.types;
    };

    Assert = {
      src = ./assert.nix;
      type = Ty.assertion;
    };
    Cmp = {
      src = ./cmp.nix;
      type = Ty.compare;
    };
    Rec = {
      src = ./rec.nix;
      type = Ty.record;
    };
    Enum = {
      src = ./enum.nix;
    };

    Fix = {
      upstream = std.fixpoints;
    };
    Nix = {
      src = ./nix.nix;
    };
    Regex = {
      src = ./regex.nix;
      upstream = std.regex;
    };
    Serde = {
      src = ./serde.nix;
      upstream = std.serde;
    };

    Applicative.upstream = std.applicative;
    Functor.upstream = std.functor;
    Monad.upstream = std.monad;
    Monoid.upstream = std.monoid;
    Semigroup.upstream = std.semigroup;

    Std = {
      src = ./std.nix;
      attrs = {
        inherit std;
        outPath = sourceInfo;
      };
    };
  };
  source = path: import path { inherit lib; };
  ty = type: {
    inherit (type) show check;
    Type = type;
  };
  tyOf = Of: {
    inherit Of;
  };
  mapMod = {
    upstream ? { }
  , without ? [ ]
  , src ? null
  , type ? null, typeOf ? null
  , attrs ? { }
  }@args: builtins.removeAttrs upstream without
    // optSet (args ? type) (ty type)
    // optSet (args ? typeOf) (tyOf type)
    // optSet (args ? src) (source src)
    // attrs;
in builtins.mapAttrs (_: mapMod) modules
