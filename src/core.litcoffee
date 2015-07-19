# Functional Programming Functions

Support for currying, partial application, and composition of functions, along with some helpers.

## no-op

Helper function for a no-op.

    noOp = ->

## identity

Helper function that always returns what's passed into it.

    identity = (x) -> x

## wrap

Another helper function that wraps a value as a function.

    wrap = (x) -> -> x

## curry

Convert a function taking N arguments into a function that takes one argument and returns another curried function taking N - 1 arguments.

    curry = (f) ->
      do cf = (ax = [])->
        (bx...) ->
          cx = ax.concat bx
          if cx.length < f.length then (cf cx) else (f cx...)

## _

Special value to allow for late-binding of an argument. See `partial`.

    _ = {}

## partial

Take a function an an argument list and return another function that takes its arguments and concatenates them with the first argument list, first performing argument substitution (see `substitute`).

    partial = (f, ax...) ->
      (bx...) ->
        bx = [].concat bx
        f (((if a == _ then bx.shift() else a) for a in ax).concat bx)...

## flip

Flip the arguments of the given function.

    flip = (f) ->
      switch f.length
        when 1 then f
        when 2 then (y, x) -> f(x, y)
        when 3 then (z, y, x) -> f(x, y, z)
        else (ax...) -> f(ax.reverse()...)

## compose

Compose a list of functions, returning a new function. You can compose functions returning promises (defined as returning a value having a `then` property) and you'll get a promise back, resolving to the result of the composition.

    compose = (fx..., f) ->
      if fx.length == 0
        f
      else
        g = compose fx...
        (ax...) ->
          if (fax = f ax...)?.then? then (fax.then g) else (g fax)

## pipe

Composition, except the functions arguments are in order of application.

    pipe = flip compose

## spread

Converts a function taking a list of arguments into a function taking an array.

    spread = (f) -> (ax) -> f ax...


## unary, binary, and ternary

These are helper functions for establishing the number of arguments.

    unary = (f) -> (x) -> f(x)
    binary = (f) -> (x,y) -> f(x,y)
    ternary = (f) -> (x,y,z) -> f(x,y,z)

## deepEqual

    deepEqual = (a, b) ->
      assert = require "assert"
      try
        assert.deepEqual a, b
        true
      catch
        false

---

    module.exports = {noOp, identity, wrap, curry, _, partial,
      flip, compose, pipe, spread, unary, binary, ternary,
      deepEqual}
