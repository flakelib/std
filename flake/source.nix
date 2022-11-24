{ lib }: let
  inherit (lib) Flake Null UInt Str Rec Ty;
in Rec.Def {
  name = "std:Flake.Source";
  Self = Flake.Source;
  fields = {
    lastModified.type = Ty.int; # TODO: type = timestamp/int;
    lastModifiedDate.type = Ty.string; # TODO: type = timestamp;
    narHash = {
      type = Ty.string; # TODO: type = hash
      optional = true;
    };
    type.type = Ty.string; # TODO: enum
    # TODO: owner repo rev dir etc optional fields
  };

  fn.lastModifiedDate = si: with UInt.parseTimestamp si.lastModified; let
    pad = v: Str.justifyRight 2 "0" (Str v);
    ymd = Str y + pad m + pad d;
    hms = pad hours + pad minutes + pad seconds;
  in si.lastModifiedDate or (ymd + hms);

  fn.fetch = si: {
    path = builtins.path {
      inherit (si) path;
      ${Null.Iif (si ? narHash) "sha256"} = si.narHash;
    };
    tarball = builtins.fetchTarball {
      inherit (si) url;
      ${Null.Iif (si ? narHash) "narHash"} = si.narHash;
    };
    git = builtins.fetchGit {
      url = si.url;
      ${Null.Iif (si ? rev) "rev"} = si.rev;
      ${Null.Iif (si ? ref) "ref"} = si.ref;
      ${Null.Iif (si ? submodules) "submodules"} = si.submodules;
    };
    github = builtins.fetchTarball {
      url = "https://api.${si.host or "github.com"}/repos/${si.owner}/${si.repo}/tarball/${si.rev}";
      ${Null.Iif (si ? narHash) "sha256"} = si.narHash;
    };
    gitlab = builtins.fetchTarball {
      url = "https://${si.host or "gitlab.com"}/api/v4/projects/${si.owner}%2F${si.repo}/repository/archive.tar.gz?sha=${si.rev}";
      ${Null.Iif (si ? narHash) "sha256"} = si.narHash;
    };
    # TODO: fetchMercurial
  }.${si.type} or (throw "Flake.Source.fetch: unsupported type ${si.type}");
} // {
  New = Flake.Source.TypeId.new;
}
