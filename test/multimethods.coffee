assert = require "assert"
Amen = require "amen"

Amen.describe "Multimethods", (context) ->

  {Method} = require "../src/multimethods"

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

  context.test "Lookups", ->

    foo = Method.create()

    Method.define foo, Number, (x) -> x + x
    Method.define foo, String, (x) -> false

    f = Method.lookup foo, [ 7 ]
    assert (f 7) == 14
