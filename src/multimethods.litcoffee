# Multimethods

Multimethods are polymorphic functions on their arguments. Methods in JavaScript objects dispatch based only on the (implicit first argument, which is the) object itself. Multimethods provide a more functional and flexible approach.

The `dispatch` function is the soul of the multimethod implementation. Our approach is iterate through all the available method implementations (`entries`) and find the best match by checking each argument (given by `ax`).

We score each match based on a set of precedence rules, from highest to lowest:

* A predicate match, ex: `even` for matching an argument that is an even number

* A value match, ex: `5` for matching a specific value

* A type match, defined by a match against the argument's constructor function

* A inherited type match, defined by `instanceof` returning true

* A variadic match, indicated with the value `_`, which automatically matches the remaining arguments.

All the arguments must match, otherwise the score is zero. If no match is found, the `default` method will be selected.

The method definition can either be a value or a function. If it's a function, the function is run using the given arguments. Otherwise, the value is returned directly.

For definitions which the value is itself a function, you must wrap the function inside another function. The `dispatch` function is not exposed directly.

    # we use the special value _ to allow for variadic matching.
    {_} = require "./core"

    dispatch = (method, ax) ->
      best = { p: 0, f: method.default }
      for [tx, f] in method.entries
        if tx.length == ax.length
          p = 0
          ai = ti = 0
          while ai < ax.length && ti < tx.length
            term = tx[ti++]
            argument = ax[ai++]
            if term == _ && ti == tx.length
              p += 1 + ax.length - ai
              break
            if term == argument
              p += 4
            else if term == argument.constructor
              p += 3
            else if term.constructor == Function && (argument instanceof term)
              p += 2
            else if term.constructor == Function && (term argument)
              p += 5
            else
              p = 0
              break
          if p >= best.p
            best = { p, f }
      if best.f.constructor == Function
        best.f ax...
      else
        best.f

The `method` function defines a new multimethod, taking an optional description of the method. This can be accessed via the `description` property of the method.

    method = (description) ->
      m = -> dispatch m, arguments
      m.entries = []
      m.default = -> throw new TypeError "No method matches arguments."
      m.description = description
      m

The `define` function adds an entry into the dispatch table. It takes the method, the signature, and the definition (implementation) as arguments.

    define = (m, terms..., f) ->
      m.entries.push [terms, f]

You can define multimethods either using `create` (ex: `Method.create`) or just using the `method` function (in the case where you don't need scoping).

    create = method
    module.exports = {create, method, define}

    {assert, describe} = require "./helpers"

    describe "Multimethods", (context) ->

      context.test "Fibonacci function", ->

        fib = method "Fibonacci sequence"

        define fib, ((n) -> n <= 0),
          -> throw new TypeError "Operand must be a postive integer"

        define fib, 1, 1
        define fib, 2, 1
        define fib, Number, (n) -> (fib n - 1) + (fib n - 2)

        assert (fib 5) == 5

      context.test "Polymorphic dispatch", ->

        class A
        class B extends A

        a = new A
        b = new B

        foo = method()
        define foo, A, -> "foo: A"
        define foo, B, -> "foo: B"
        define foo, A, B, -> "foo: A + B"
        define foo, B, A, -> "foo: B + A"
        define foo, a, b, -> "foo: a + b"


        assert (foo b) == "foo: B"
        assert (foo a, b) == "foo: a + b"
        assert (foo b, a) == "foo: B + A"
        assert.throws ->
          foo b, a, b
