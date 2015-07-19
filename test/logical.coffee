assert = require "assert"
Amen = require "amen"

Amen.describe "Logical functions", (context) ->

  {negate, both, either, neither, same, different} = require "../src/logical"
  
  context.test "negate", -> assert !((negate -> true)())
  context.test "both"
  context.test "either"
  context.test "neither"
  context.test "same"
  context.test "different"
