with rec {
  set = import ./set.nix;
  types = import ./types.nix;
};

rec {
  /* id :: a -> a
  */
  id = x: x;

  /* const :: a -> b -> a
  */
  const = a: _: a;

  /* compose :: (b -> c) -> (a -> b) -> (a -> c)
  */
  compose = bc: ab: a: bc (ab a);

  /* flip :: (a -> b -> c) -> b -> a -> c
  */
  flip = f: b: a: f a b;

  args = f:
    if f ? __functor then f.__functionArgs or (args (f.__functor f))
    else builtins.functionArgs f;

  setArgs = args: f: set.assign "__functionArgs" args (toFunctor f);

  copyArgs = src: dst: setArgs (args src) dst;

  isLambda = builtins.isFunction;
  isFunctor = f: f ? __functor;

  toFunctor = f: if isLambda f then {
    __functor = self: f;
  } else f;

  scopedArgs = scope: f: builtins.intersectAttrs (args f) scope;

  wrap = f: {
    inherit f;
    __functionArgs = args f;
    __functor = self: self.f;
  };

  wrapScoped = scope: f: wrap f // {
    inherit scope;
    __functor = self: args: self.f (scopedArgs self.scope self.f // args);
  };

  overridable = f: arg: let
    value = f arg;
    applyArgs = arg: o: if types.function.check o then o arg else o;
    override = {
      __functor = self: o: overridable self.f (self.args // applyArgs self.args o);
      __functionArgs = args f;
      inherit f value;
      args = arg;
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
  in if builtins.isAttrs value then value // {
    inherit override;
    ${if value ? overrideAttrs then "overrideAttrs" else null} = overrideAttrs override;
    # TODO: overrideDerivation?
  } else if types.function.check value then toFunctor value // {
    inherit override;
  } else value;
}
