{ lib }: let
  inherit (lib) Serde;
in {
  Read = builtins.readFile;

  WithJSON = Serde.fromJSON;
  ReadJSON = path: Serde.WithJSON (Serde.Read path);

  WithTOML = Serde.fromTOML;
  ReadTOML = path: Serde.WithTOML (Serde.Read path);
}
