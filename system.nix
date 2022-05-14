{ lib }: let
  inherit (lib) System Rec Set Ty;
in Rec.Def {
  name = "std:System";
  Self = System;
  coerce.${Ty.string.name} = System.WithDouble; # TODO: detect triple vs double?
  coerce.${Ty.attrs.name} = System.New;
  fields = {
    system = { };
    config.optional = true;
    libc.optional = true;
    # TODO
  };
  fn.double = system: system.system;
  fn.triple = system: Set.lookup "config";
  fn.data = system: Rec.fields System system;
  fn.isSimple = system: Set.keys (System.data system) == [ "system" ];
  fn.serialize = system: if System.isSimple system
    then System.double system
    else System.data system;
} // {
  WithDouble = system: System.New {
    inherit system;
  };
  WithTriple = config: System.New {
    inherit config;
  };
  New = sys: System.TypeId.new sys;
}
