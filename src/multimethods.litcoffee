# Multimethods

[Multimethods][1] are polymorphic functions on their arguments. Methods in JavaScript objects dispatch based only on the (implicit first argument, which is the) object itself. Multimethods provide a more functional and flexible approach.

[1]:https://en.wikipedia.org/wiki/Multiple_dispatch

The `dispatch` function is the soul of the multimethod implementation. Our approach is iterate through all the available method implementations (`entries`) and find the best match by checking each argument (given by `ax`).

We score each match based on a set of precedence rules, from highest to lowest:

* A predicate match, ex: `even` for matching an argument that is an even number

* A value match, ex: `5` for matching a specific value

* A type match, defined by a match against the argument's constructor function

* A inherited type match, defined by `instanceof` returning true

All the arguments must match, otherwise the score is zero. If no match is found, the `default` method will be selected.

The method definition can either be a value or a function. If it's a function, the function is run using the given arguments. Otherwise, the value is returned directly.

For definitions which the value is itself a function, you must wrap the function inside another function. The `dispatch` function is not exposed directly.

A map function allows for the transformation of the arguments for matching purposes. For example, variadic functions can be implemented by simply providing a variadic map function that returns the arguments as an Array.

    lookup = (method, ax) ->
      best = { p: 0, f: method.default }
      bx = if method.map? then (method.map ax...) else ax

      for [tx, f] in method.entries
        if tx.length == bx.length
          p = 0
          bi = ti = 0
          while bi < bx.length && ti < tx.length
            term = tx[ti++]
            arg = bx[bi++]
            if term == arg
              p += 5
            else if term?.constructor == Function
              if arg?
                if term == arg.constructor
                  p += 4
                else if (arg instanceof term)
                  p += 2
                else if arg.prototype instanceof term
                  p += 1
                else if term != Boolean && (term arg) == true
                    p += 5
                else
                  p = 0
                  break
              else if term != Boolean && (term arg) == true
                  p += 5
              else
                p = 0
                break
            else
              p = 0
              break
          if p > 0 && p >= best.p
            best = { p, f }

      if best.f.constructor == Function
        best.f
      else
        -> best.f

    dispatch = (method, ax) ->
      f = lookup method, ax
      f ax...

The `method` function defines a new multimethod, taking an optional description of the method. This can be accessed via the `description` property of the method.

    create = (options) ->
      m = (args...) -> dispatch m, args
      m.entries = []
      m[k] = v for k, v of options
      m.default ?= -> throw new TypeError "No method matches arguments."
      m

The `define` function adds an entry into the dispatch table. It takes the method, the signature, and the definition (implementation) as arguments.

    define = (m, terms..., f) ->
      m.entries.push [terms, f]

---

    Method = {create, define, lookup}
    module.exports = {Method}
