import dicelib

str_expr = "1d4 + 2d6"
expr = dicelib.Expression.from_str(str_expr)
print(expr)
print(expr.full_verbose_roll())
