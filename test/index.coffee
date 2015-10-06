assert = require "assert"
Amen = require "amen"

Amen.describe "Fairmont (bundled)", (context) ->

  context.test "Require from each module", ->
    assert require "fairmont-core"
    assert require "fairmont-helpers"
    assert require "fairmont-multimethods"
    assert require "fairmont-reactive"
    assert require "fairmont-process"
    assert require "fairmont-filesystem"
