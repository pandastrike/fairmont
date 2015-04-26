# Functional Programming Functions

Support for currying, partial application, and composition of functions, along with some helpers.

    {assert, describe} = require "./helpers"

    describe "Functional programming functions", (context) ->

## deep_equal

      deep_equal = (a, b) ->
        assert = require "assert"
        try
          assert.deepEqual a, b
          true
        catch
          false

      context.test "deep_equal", ->
        assert deep_equal {a: 1, b: 2}, {b: 2, a: 1}
        assert !deep_equal {a: 1, b: 2}, {a: 1, b: 1}

## no-op

Helper function for a no-op.

      no_op = ->

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

      context.test "curry", ->
        f = curry (x, y, z) -> {x, y, z}
        assert deep_equal (f 1, 2, 3), {x: 1, y: 2, z: 3}
        g = f 3, 2
        assert deep_equal (g 1), {x: 3, y: 2, z: 1}

## _

Special value to allow for late-binding of an argument. See `partial`.

      _ = {}


## partial

Take a function an an argument list and return another function that takes its arguments and concatenates them with the first argument list, first performing argument substitution (see `substitute`).

      partial = (f, ax...) ->
        (bx...) ->
          bx = [].concat bx
          f (((if a == _ then bx.shift() else a) for a in ax).concat bx)...

      context.test "partial", ->
        {pow} = Math
        square = partial pow, _, 2
        assert (square 3) == 9

## flip

Flip the arguments of the given function.

      flip = (f) ->
        switch f.length
          when 1 then f
          when 2 then (y, x) -> f(x, y)
          when 3 then (z, y, x) -> f(x, y, z)
          else (ax...) -> f(ax.reverse()...)

      context.test "flip", ->
        {pow} = Math
        square =  (curry flip pow)(2)
        assert (square 3) == 9


## compose

Compose a list of functions, returning a new function. You can compose functions returning promises (defined as returning a value having a `then` property) and you'll get a promise back, resolving to the result of the composition.

      compose = (fx..., f) ->
        if fx.length == 0
          f
        else
          g = compose fx...
          (ax...) ->
            if (f_ax = f ax...).then? then (f_ax.then g) else (g f_ax)


      context.test "compose", ->
        data = foo: 1, bar: 2, baz: 3
        {parse, stringify} = JSON
        clone = compose parse, stringify
        assert deep_equal (clone data), data
        {promise} = require "when"
        _stringify = (x) ->
          promise (resolve) ->
            setTimeout (-> resolve stringify x), 100
        _parse = (s) ->
          promise (resolve) ->
            setTimeout (-> resolve parse s), 100
        clone_1 = compose parse, _stringify
        clone_2 = compose _parse, stringify
        clone_3 = compose _parse, _stringify
        assert deep_equal (yield clone_1 data), data
        assert deep_equal (yield clone_2 data), data
        assert deep_equal (yield clone_3 data), data



## pipe

Composition, except the functions arguments are in order of application.

      pipe = flip compose

      context.test "pipe", ->
        data = foo: 1, bar: 2, baz: 3
        {parse, stringify} = JSON
        clone = pipe stringify, parse
        assert deep_equal (clone data), data

## variadic

Converts a function taking a list of arguments into a function taking an array.

      variadic = (f) -> (ax) -> f ax...


## unary, binary, and ternary

These are helper functions for establishing the number of arguments.

      unary = (f) -> (x) -> f(x)
      binary = (f) -> (x,y) -> f(x,y)
      ternary = (f) -> (x,y,z) -> f(x,y,z)

---

      module.exports = {deep_equal, no_op, identity, wrap, curry, _, partial,
        flip, compose, pipe, variadic, unary, binary, ternary}
