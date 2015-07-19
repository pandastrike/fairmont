assert = require "assert"
Amen = require "amen"

Amen.describe "Numeric functions", (context) ->

  {gt, lt, gte, lte, add, sub, mul, div, mod,
    even, odd, min, max, abs} = require "../src/numeric"

  context.test "lt", -> assert lt 6, 5

  context.test "odd", -> assert odd 5
