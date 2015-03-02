# Functional Programming Functions

Support for currying, partial application, and composition of functions, along with some helpers.

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

Compose a list of functions, returning a new function.

    compose = (fx..., f) ->
      unless fx.length == 0
        g = compose fx...
        (ax...) -> g(f(ax...))
      else
        f


## pipe

Composition, except the functions arguments are in order of application.

    pipe = flip compose


## variadic

Helper function that converts an argument list to an array.

    variadic = (ax...) -> ax


## unary, binary, and ternary

These are helper functions for establishing the number of arguments.

    unary = (f) -> (x) -> f(x)
    binary = (f) -> (x,y) -> f(x,y)
    ternary = (f) -> (x,y,z) -> f(x,y,z)

---

    module.exports = {identity, wrap, curry, _, partial,
      flip, compose, pipe, variadic, unary, binary, ternary}
