{
  description = "No-nixpkgs standard library for the Nix expression language";

  outputs = { self }: let
    systems = [ "x86_64-linux" ];
    forEachSystem = f: self.lib.set.fromList (
      self.lib.list.map (system: { _0 = system; _1 = f system; }) systems
    );
  in {
      lib = import ./default.nix;
      checks = forEachSystem (system: {
        test = import ./test { inherit system; };
      });
    };
}
