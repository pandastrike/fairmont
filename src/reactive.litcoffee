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

## start

      # TODO: need to add synchronous version
  
      {async} = require "./generator"
      start = async (i) ->
        loop
          {done, value} = yield i()
          break if done


      # TODO: need to add synchronous version

      {curry} = require "./core"
      {iterator} = require "./iterator"
      pump = curry (s, i) ->
        iterator ->
          {done, value} = yield i()
          if !done
            value: (s.write value)
            done: false
          else
            s.end()
            {done}


## tee

      # TODO: need to add synchronous version

      {curry} = require "./core"
      {iterator} = require "./iterator"
      tee = curry (f, i) ->
        iterator ->
          {done, value} = yield i()
          (f value) unless done
          {done, value}


---

      module.exports = {flow, start, pump}
