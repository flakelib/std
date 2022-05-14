{ lib }: let
  inherit (lib) Fn Set Bool List;
in {
  toLambda = f: if Fn.isFunctor f then f.__functor f else f;

  toSet = Fn.toFunctor;

  not = f: arg: ! f arg;

  pipe = List.foldl' (Fn.flip Fn.compose) Fn.id;

  scopedArgs = scope: f: Set.intersect (Fn.args f) scope;

  wrap = f: {
    inherit f;
    __functionArgs = Fn.args f;
    __functor = self: self.f;
  };

  wrapScoped = scope: f: Fn.wrap f // {
    inherit scope;
    __functor = self: args: self.f (Fn.scopedArgs self.scope self.f // args);
  };

  overridable = f: args: let
    value = f args;
    applyArgs = args: o: if Fn.check o then o args else o;
    override = {
      __functor = self: o: Fn.overridable self.f (self.args // applyArgs self.args o);
      __functionArgs = Fn.args f;
      inherit f args value;
      ${if value ? overrideAttrs then "overrideAttrs" else null} = value.overrideAttrs;
    };
    overrideAttrs = override': o: let
      value = override'.value.overrideAttrs o;
      override = override' // {
        inherit value;
        inherit (value) overrideAttrs;
      };
    in value // {
      inherit override;
      overrideAttrs = overrideAttrs override;
    };
  in if Set.check value then value // {
    inherit override;
    ${Bool.toNullable (value ? overrideAttrs) "overrideAttrs"} = overrideAttrs override;
    # TODO: overrideDerivation?
  } else if Fn.check value then Fn.toFunctor value // {
    inherit override;
  } else value;
}
