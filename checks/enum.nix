{ lib }: let
  inherit (lib) Enum Ty Assert;
  None = "none";
  Some = "some";
  MyEnum = Enum.Def {
    name = "test:MyEnum";
    var = {
      inherit None Some;
    };
  };
  ListEnum = Enum {
    name = "test:ListEnum";
    var = [ None Some null ];
  };
in {
  name = "enum";
  assertions = {
    eq = Assert.Eq {
      exp = None;
      val = MyEnum.None;
    };
    check = Assert.True {
      val = MyEnum.check None;
    };
    values = Assert.Eq {
      exp = [ None Some ];
      val = Enum.values MyEnum;
    };
    check-list = Assert.True {
      val = ListEnum.check None;
    };
    check-false = Assert.True {
      val = ! MyEnum.check "mew";
    };
    show = Assert.Eq {
      exp = "${MyEnum.TypeId.name}.None";
      val = MyEnum.show MyEnum.None;
    };
    /*show-dyn = Assert.Eq { # TODO: enum tagging
      exp = "${MyEnum.TypeId.name}.None";
      val = Ty.Show (Enum.tag MyEnum MyEnum.None);
    };*/
  };
}
