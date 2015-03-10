# General Purpose Functions

    {describe, assert} = require "./helpers"

    describe "General functions", (context) ->

## abort

Simple wrapper around `process.exit(-1)`.

      abort = -> process.exit -1

      context.test "abort"

## memoize

A very simple way to cache results of functions that take a single argument. Also takes an optional hash function that defaults to calling `toString` on the function's argument.

      memoize = do (_hash = undefined) ->
        _hash = (x) -> x.toString()
        (fn, hash = _hash, memo = {}) ->
          (x) -> memo[hash x] ?= fn x

      context.test "memoize"

## timer

Set a timer. Takes an interval in microseconds and an action. Returns a function to cancel the timer. Basically, a more convenient way to call `setTimeout` and `clearTimeout`.

      timer = (wait, action) ->
        id = setTimeout(action, wait)
        -> clearTimeout( id )
      context.test "timer"

## sleep

Returns a promise that yields after a given interval.

      sleep = (interval) ->
        {promise} = require "when"
        promise (resolve, reject) ->
          timer interval, -> resolve()

      context.test "sleep"


## shell

Execute a shell command. Returns a promise that resolves to an object with properties `stdout` and `stdin`, or is rejected with an error.

      shell = (command) ->
        {promise} = require "when"
        {exec} = require "child_process"
        promise (resolve, reject) ->
          exec command, (error, stdout, stderr) ->
            if error
              reject error
            else
              resolve {stdout, stderr}

      context.test "shell", ->
        assert (yield shell "ls ./test").stdout.trim?

## times

Run a function N number of times.

      {curry} = require "./core"
      times = curry (fn, n) -> fn() until n-- == 0

      context.test "times", ->
        do (n = 0) ->
          assert (times (-> ++n), 3).length == 3

---

      module.exports = {times, shell, sleep, timer, memoize, abort}

Load the rest of the functions.

      {include} = require "./object"
      include module.exports, require "./core"
      include module.exports, require "./logical"
      include module.exports, require "./numeric"
      include module.exports, require "./type"
      include module.exports, require "./array"
      include module.exports, require "./iterator"
      include module.exports, require "./crypto"
      include module.exports, require "./fs"
      include module.exports, require "./object"
      include module.exports, require "./string"
      include module.exports, require "./generator"
