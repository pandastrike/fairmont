# Reactive Programming Functions

    {assert, describe} = require "./helpers"

    describe "Reactive programming functions", (context) ->


## flow

      {Method} = require "./multimethods"
      hoist = Method.create()
      Method.define hoist, isFunction, map
      Method.define hoist, isGeneratorFunction, compose map, async
      Method.define hoist, isIterator, identity
      Method.define hoist, isAsynchronousIterator, identity

      {reduce} = require "./iterator"
      flow = ([i, fx...]) ->
        reduce i, ((i, f) -> ((hoist f) i)), fx

      context.test "flow", ->
        i = flow [
          stream createReadStream "./test/lines.txt"
          lines
        ]
        yield i()
        console.log (yield i())
