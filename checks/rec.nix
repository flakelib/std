{ lib }: let
  inherit (lib) Rec Ty Assert;
  MyRec = Rec.Def {
    name = "test:MyRec";
    fn = {
      add = self: num: self.value + num;
      setAdd.fn = { self, num ? 1 }: MyRec.add self num;
      # TODO: setAdd = { expose = true; selfArg = "self"; };
      neg.fn = self: -self.value;
      neg = {
        memoize = true;
        expose = true;
      };
      sub = {
        fn = self: num: self.value - num;
        expose = true;
      };
    };
    fields.value = {
      ty = Ty.int;
    };
    coerce.${toString (Ty.TypeId.ForType Ty.int)} = value: Rec.new MyRec { inherit value; };
  } // {
    Default = Rec.new MyRec {
      value = 0;
    };
  };
in {
  name = "rec";
  assertions = {
    default = Assert.Eq {
      exp = 0;
      val = MyRec.Default.value;
    };
    coerce-value = Assert.Eq {
      val = (MyRec 0).value;
      exp = MyRec.Default.value;
    };
    coerce-self = Assert.Eq {
      val = (MyRec MyRec.Default).value;
      exp = MyRec.Default.value;
    };
    expose = Assert.Eq {
      exp = 0;
      val = MyRec.Default.neg;
    };
    memo-value = Assert.Eq {
      exp = MyRec.neg MyRec.Default;
      val = (Rec.memoizedValues MyRec MyRec.Default).neg;
    };
    /*memo = Assert.Ne {
      val = MyRec.neg;
      exp = (Rec.fn MyRec).neg;
    };
    no-memo = Assert.Eq {
      val = MyRec.sub;
      exp = (Rec.fn MyRec).sub;
    };*/
    method = Assert.Eq {
      val = MyRec.add MyRec.Default 1;
      exp = 1;
    };
    set-method = Assert.Eq {
      val = MyRec.setAdd { self = MyRec.Default; };
      exp = 1;
    };
    /*new-check = Assert.Throws { # TODO
      val = MyRec.New { value = "not a number"; };
    };*/
    /*self-method = { # TODO
      val = MyRec.Default.setAdd { };
      exp = 1;
    };*/
    show = Assert.Eq {
      val = Ty.Show MyRec.Default;
      exp = "${MyRec.TypeId.name}{ value = ${toString MyRec.Default.value}; }";
    };
  };
}
