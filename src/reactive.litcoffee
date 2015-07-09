# Reactive Programming Functions

    {assert, describe} = require "./helpers"

    describe "Reactive programming functions", (context) ->


## flow

      FS = require "fs"
      {reduce} = require "./iterator"

      flow = ([i, fx...]) -> reduce i, ((i,f) -> f i), fx

      context.test "flow", ->
        {events, lines} = require "./iterator"
        i = flow [
          events "data", FS.createReadStream "./test/lines.txt"
          lines
        ]
        assert (yield i()).value == "one"
        assert (yield i()).value == "two"
        assert (yield i()).value == "three"
        assert (yield i().done)
