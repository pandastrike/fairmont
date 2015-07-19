# Numeric Functions

    {curry, partial} = require "./core"
    {negate} = require "./logical"

## gt, lt, gte, lte

    gte = curry (x, y) -> y >= x
    lte = curry (x, y) -> y <= x
    gt = curry (x, y) -> y > x
    lt = curry (x, y) -> y < x

    add = curry (x, y) -> x + y
    sub = curry (x, y) -> y - x
    mul = curry (x, y) -> x * y
    div = curry (x, y) -> y / x
    mod = curry (x, y) -> y % x == 0

## odd, even

    even = mod 2
    odd = negate even

## Functions exported from Math

    {min, max, abs, pow} = Math

---

    module.exports = {gt, lt, gte, lte, add, sub, mul, div, mod,
      even, odd, min, max, abs}
