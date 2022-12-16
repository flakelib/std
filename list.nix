{ lib }: let
  inherit (lib.Std.std) list;
  inherit (lib) List Opt Ty;
in {
  # backcompat
  head = list.unsafeHead;
  tail = list.unsafeTail;
  init = list.unsafeInit;
  last = list.unsafeLast;
  elemAt = list.unsafeIndex;
  index = list.unsafeIndex;

  foldl = List.foldl';

  Nil = List.nil;
  One = List.singleton;

  # From :: [x] | x -> [x]
  From = l: if Ty.list.check l then l else [ l ];

  Of = Ty.listOf;
}
