# Logical Functions

    {curry} = require "./core"

    assert = require "assert"

    f_and = curry (f, g) -> -> (f arguments...) && (g arguments...)
    f_or = curry (f, g) -> -> (f arguments...) || (g arguments...)
    f_not = (f) -> -> !(f arguments...)

    assert !((f_not -> true)())

    f_eq = curry (f, g) -> -> (f arguments...) == (g arguments...)
    f_neq = curry (x,y) -> -> (f arguments...) != (g arguments...)

---

    module.exports = {f_and, f_or, f_not, f_eq, f_neq}
