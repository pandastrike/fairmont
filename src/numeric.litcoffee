# Numeric Functions

    {curry, partial} = require "./core"
    {f_not} = require "./logical"

    assert = require "assert"

## gt, lt, gte, lte

    gte = curry (x, y) -> y >= x
    lte = curry (x, y) -> y <= x
    gt = curry (x, y) -> y > x
    lt = curry (x, y) -> y < x

    assert lt 6, 5

    add = curry (x, y) -> x + y
    sub = curry (x, y) -> y - x
    mul = curry (x, y) -> x * y
    div = curry (x, y) -> y / x
    mod = curry (x, y) -> y % x == 0

## odd, even

    even = mod 2
    odd = f_not even

    assert odd 5


    {min, max} = Math

---

    module.exports = {gt, lt, gte, lte, add, sub, mul, div, mod,
      even, odd, min, max}
