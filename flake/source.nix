{ lib }: let
  inherit (lib) Flake Null Rec Ty;
in Rec.Def {
  name = "std:Flake.Source";
  Self = Flake.Source;
  fields = {
    lastModified.type = Ty.int; # TODO: type = timestamp/int;
    narHash = {
      type = Ty.string; # TODO: type = hash
      optional = true;
    };
    type.type = Ty.string; # TODO: enum
    # TODO: owner repo rev dir etc optional fields
  };
  fn.fetch = si: {
    path = builtins.path {
      inherit (si) path;
      ${Null.Iif (si ? narHash) "narHash"} = si.narHash;
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
