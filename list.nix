{ lib }: let
  inherit (lib) List Opt Ty;
in {
  foldl = List.foldl';

  Nil = List.nil;
  One = List.singleton;

  # From :: [x] | x -> [x]
  From = l: if Ty.list.check l then l else [ l ];

  Of = Ty.listOf;
}
