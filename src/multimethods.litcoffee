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

    dispatch = (method, ax) ->
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
            else
              p = 0
              break
          if p > 0 && p >= best.p
            best = { p, f }

      if best.f.constructor == Function
        best.f ax...
      else
        best.f

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

You can define multimethods either using `create` (ex: `Method.create`) or just using the `method` function (in the case where you don't need scoping).

    Method = {create, define}
    module.exports = {Method}

    {assert, describe} = require "./helpers"

    describe "Multimethods", (context) ->

      context.test "Fibonacci function", ->

        fib = Method.create description: "Fibonacci sequence"

        Method.define fib, ((n) -> n <= 0),
          -> throw new TypeError "Operand must be a postive integer"

        Method.define fib, 1, 1
        Method.define fib, 2, 1
        Method.define fib, Number, (n) -> (fib n - 1) + (fib n - 2)

        assert (fib 5) == 5

      context.test "Polymorphic dispatch", ->

        class A
        class B extends A

        a = new A
        b = new B

        foo = Method.create()
        Method.define foo, A, -> "foo: A"
        Method.define foo, B, -> "foo: B"
        Method.define foo, A, B, -> "foo: A + B"
        Method.define foo, B, A, -> "foo: B + A"
        Method.define foo, a, b, -> "foo: a + b"


        assert (foo b) == "foo: B"
        assert (foo a, b) == "foo: a + b"
        assert (foo b, a) == "foo: B + A"
        assert.throws ->
          foo b, a, b

      context.test "Variadic arguments", ->

        bar = Method.create map: (x) -> [ x ]
        Method.define bar, String, (x, a...) -> a[0]
        Method.define bar, Number, (x, a...) -> x

        assert (bar "foo", 1, 2, 3) == 1

      context.test "Predicate functions", ->

        baz = Method.create()
        Method.define baz, Boolean, -> false
        Method.define baz, ((x) -> x == 7), (x) -> true

        assert (baz 7)
        assert.throws -> (baz 6)

      context.test "Class methods", ->

        class A
        class B extends A

        foo = Method.create()

        Method.define foo, A, -> true

        assert (foo B)

      context.test "Multimethods are functions", ->

        assert Method.create().constructor == Function
