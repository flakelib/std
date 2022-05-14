{ lib }: let
  inherit (lib) Cmp Bool Ty;
in {
  Equal = "EQ";
  GreaterThan = "GT";
  LessThan = "LT";

  Compare = lhs: rhs: let
    toInt = x: if Ty.bool.check x then Bool.toInt x else x;
    lhs' = toInt lhs;
    rhs' = toInt rhs;
    comparable = x: ! Ty.function.check x && ! Ty.attrs.check x && ! Ty.list.check x;
  in if lhs == rhs then Cmp.Equal
    else if comparable lhs && comparable rhs && lhs' < rhs' then Cmp.LessThan
    else Cmp.GreaterThan;

  eq = cmp: toString cmp == Cmp.Equal;
  ne = cmp: toString cmp != Cmp.Equal;

  sign = cmp: {
    ${Cmp.Equal} = "=";
    ${Cmp.GreaterThan} = ">";
    ${Cmp.LessThan} = "<";
  }.${toString cmp};
}
