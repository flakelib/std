with rec {
  set = import ./set.nix;
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
}
