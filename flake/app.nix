{ lib }: let
  inherit (lib) Flake Drv Fn Ty Str;
  inherit (Flake) App;
in {
  ForProgram = program: App.TypeId.new {
    inherit program;
  };

  ForDrv = drv: App.ForProgram (Drv.mainProgram drv);

  From = v: if Ty.pathlike.check v then App.ForProgram v
    else if Ty.drv.check v then App.ForDrv v
    else if App.TypeId.ty.check v then v
    else throw "std.Flake.App: cannot convert ${Ty.Show v}";

  __functor = App: App.From;

  TypeId = Ty.TypeId.new rec {
    name = "app";
    ty = Ty.mkType {
      inherit name;
      description = "flake app";
      show = app: "FlakeApp(${Str.raw app.program})";
      check = app: app.type or null == Flake.App.TypeId.name && app ? program;
    };
    new = { program }: {
      type = Flake.App.TypeId.name;
      inherit program;
    };
  };
}
