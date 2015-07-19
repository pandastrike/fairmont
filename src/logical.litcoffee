# Logical Functions

    {curry} = require "../src/core"

# negate

    negate = (f) -> -> !(f arguments...)

# both

    both = curry (f, g) -> -> (f arguments...) && (g arguments...)

# either

    either = curry (f, g) -> -> (f arguments...) || (g arguments...)

# neither

    neither = negate either

# same

    same = curry (f, g) -> -> (f arguments...) == (g arguments...)

# different

    different = curry (x,y) -> -> (f arguments...) != (g arguments...)

---

    module.exports = {negate, both, either, neither, same, different}
