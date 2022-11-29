{ lib, std, sourceInfo }: let
  inherit (lib) Ty;
  source = path: import path { inherit lib; };
  ty = type: {
    inherit (type) show check;
    Type = type;
  };
in {
  Bool = std.bool // ty Ty.bool // source ./bool.nix;
  Drv = ty Ty.drv // source ./drv.nix;
  Flake = ty Ty.flake // source ./flake;
  Fn = std.function // ty Ty.function // source ./fn.nix;
  List = std.list // ty Ty.list // source ./list.nix;
  NonEmpty = std.nonempty // ty Ty.nonEmptyList // source ./nonempty.nix;
  Null = std.nullable // ty Ty.null // source ./null.nix;
  Int = ty Ty.int // source ./int.nix;
  UInt = ty Ty.u32 // source ./uint.nix;
  Float = ty Ty.float // source ./float.nix;
  Complex = ty Ty.complex // source ./complex.nix;
  Opt = std.optional // source ./opt.nix;
  Path = ty Ty.path // source ./path.nix;
  Set = std.set // ty Ty.attrs // source ./set.nix;
  Str = std.string // ty Ty.string // source ./str.nix;
  System = source ./system.nix;
  Ty = std.types // source ./ty.nix;

  Assert = ty Ty.assertion // source ./assert.nix;
  Cmp = ty Ty.compare // source ./cmp.nix;
  Rec = ty Ty.record // source ./rec.nix;
  Enum = source ./enum.nix;

  Fix = std.fixpoints;
  Nix = source ./nix.nix;
  Regex = std.regex // source ./regex.nix;
  Serde = std.serde // source ./serde.nix;

  Applicative = std.applicative;
  Functor = std.functor;
  Monad = std.monad;
  Monoid = std.monoid;
  Semigroup = std.semigroup;

  Std = {
    inherit std;
    outPath = sourceInfo;
  } // source ./std.nix;
}
