{
  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };
  outputs = { self, flake-compat }: {
    lib.loadFlake = { src, system ? "unknown-system", ... }@args: (import flake-compat args).defaultNix;
  };
}
