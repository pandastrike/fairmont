# Logical Functions

    {describe, assert} = require "./helpers"

    {curry} = require "./core"

    describe "Logical functions", (context) ->

# f_and

      f_and = curry (f, g) -> -> (f arguments...) && (g arguments...)

# f_or

      f_or = curry (f, g) -> -> (f arguments...) || (g arguments...)

# negate

      negate = (f) -> -> !(f arguments...)

      context.test "negate", ->
        assert !((negate -> true)())

# f_eq

      f_eq = curry (f, g) -> -> (f arguments...) == (g arguments...)

# f_neq

      f_neq = curry (x,y) -> -> (f arguments...) != (g arguments...)

---

      module.exports = {f_and, f_or, negate, f_eq, f_neq}
