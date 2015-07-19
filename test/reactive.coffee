assert = require "assert"
Amen = require "amen"

Amen.describe "Reactive programming functions", (context) ->

    {flow} = require "../src/reactive"
    {events, lines} = require "../src/iterator"
    fs = require "fs"

    context.test "flow", ->

      i = flow [
        events "data", fs.createReadStream "./test/data/lines.txt"
        lines
      ]

      assert (yield i()).value == "one"
      assert (yield i()).value == "two"
      assert (yield i()).value == "three"
      assert (yield i().done)
