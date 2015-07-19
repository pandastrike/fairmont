assert = require "assert"
Amen = require "amen"

Amen.describe "General functions", (context) ->

  {times, shell, sleep, timer, memoize, abort,
    times, benchmark, empty, length} = require "../src/util"

  context.test "abort"
  context.test "memoize"
  context.test "timer"
  context.test "sleep"
  context.test "shell", ->
    assert (yield shell "ls ./test").stdout.trim?

  context.test "times", ->
    n = 0
    assert (times (-> ++n), 3).length == 3

  context.test "benchmark"

  context.test "empty", ->
    assert empty []
    assert empty ""
    assert empty {}
    assert ! empty [1]
    assert ! empty "abc"
    assert ! empty a: 0
    assert empty undefined
    assert ! empty true

  context.test "length", -> assert (length []) == 0
