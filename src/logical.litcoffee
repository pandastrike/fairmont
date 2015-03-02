# Logical Functions

    {describe, assert} = require "./helpers"

    {curry} = require "./core"

    describe "Logical functions", (context) ->

# f_and

      f_and = curry (f, g) -> -> (f arguments...) && (g arguments...)

# f_or

      f_or = curry (f, g) -> -> (f arguments...) || (g arguments...)

# f_not

      f_not = (f) -> -> !(f arguments...)

      context.test "f_not", ->
        assert !((f_not -> true)())

# f_eq

      f_eq = curry (f, g) -> -> (f arguments...) == (g arguments...)

# f_neq

      f_neq = curry (x,y) -> -> (f arguments...) != (g arguments...)

---

      module.exports = {f_and, f_or, f_not, f_eq, f_neq}
