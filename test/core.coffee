assert = require "assert"
Amen = require "amen"
Core = require "../src/core"

Amen.describe "Core functions", (context) ->

  context.test "noOp"

  context.test "identity"

  context.test "wrap"

  context.test "curry"

  context.test "partial", ->
    {partial, _} = Core
    {pow} = Math
    square = partial pow, _, 2
    assert (square 3) == 9

  context.test "flip", ->
    {flip, curry} = Core
    {pow} = Math
    square =  (curry flip pow)(2)
    assert (square 3) == 9

  context.test "compose"

  context.test "pipe"

  context.test "spread"

  context.test "unary"

  context.test "binary"

  context.test "ternary"

  context.test "deepEqual"
