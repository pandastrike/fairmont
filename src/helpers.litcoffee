# Helpers

These functions are intended to facilitate writing tests within a literate programming context. They are not part of Fairmont-proper, but instead used to write the tests.

The basic idea is to check the script name and provide pass-through helpers unless the name is `test`. In which case, we provide Amen's `describe` function and Node's `assert`.

    script = process.argv[1]

    if script?.match /test.litcoffee$/

      assert = require "assert"
      Amen = require "amen"
      module.exports = {assert, describe: -> Amen.describe arguments...}

    else

      module.exports =
        assert: ->
        describe: (string, fn) -> fn test: ->
