{ pkgs, lib, ... }: with lib; let
  test = pkgs.ci.command {
    name = "test";
    command = ''
      nix-build --no-out-link test
    '';
    impure = true;
  };
in {
  name = "nix-std";
  ci.gh-actions.enable = true;
  tasks = {
    test.inputs = singleton test;
  };
}
