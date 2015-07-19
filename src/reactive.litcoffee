# Reactive Programming Functions

## flow

      FS = require "fs"
      {reduce} = require "./iterator"

      flow = ([i, fx...]) -> reduce i, ((i,f) -> f i), fx

## start

      # TODO: need to add synchronous version

      {async} = require "./async"
      start = async (i) ->
        loop
          {done, value} = yield i()
          break if done


## pump

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


## throttle

      throttle = curry (ms, i) ->
        last = 0
        iterator ->
          loop
            {done, value} = yield i()
            break if done
            now = Date.now()
            break if now - last >= ms
          last = now
          {done, value}

---

      module.exports = {flow, start, pump, tee, throttle}
