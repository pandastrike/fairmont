assert = require "assert"
Amen = require "amen"

Amen.describe "Object functions", (context) ->

  {include, extend, merge, clone,
    properties, property, delegate, bind, detach,
    has, keys, values, pairs, pick, omit, query,
    toJSON, fromJSON} = require "../src/object"

  {deepEqual, compose} = require "../src/core"

  context.test "include"

  context.test "merge"

  context.test "clone", ->
    person =
      name: "Steve Jobs"
      address:
        street: "1 Infinite Loop"
        city: "Cupertino, CA"
        zip: 95014
      birthdate: new Date 'Feb 24, 1955'
      regex: /foo.*/igm


    assert.notEqual  (clone person), person
    assert.deepEqual (clone person), person

  context.test "property", ->
    a = { foo: 1, bar: 2, baz: { foo: 2 }}
    assert (property "foo", a) == 1
    bazFoo = (compose (property "foo"), (property "baz"))
    assert (bazFoo a) == 2

  context.test "delegate"

  context.test "bind", ->
    trim = bind String::trim, "foo "
    assert (trim()), "foo"

  context.test "detach", ->
    trim = detach String::trim
    assert (trim "foo "), "foo"

  context.test "properties", ->
    class A
      properties @::,
        foo:
          get: -> @_foo
          set: (v) -> @_foo = v

    a = new A
    a.foo = "bar"
    assert a.foo == "bar"
    assert a._foo?

  context.test "has", ->
    assert (has "a" , {a: 1})

  context.test "keys", ->
    assert ("a" in keys {a: 1})

  context.test "values", ->
    assert (1 in values {a: 1})

  context.test "pairs", ->
    assert deepEqual (pairs {a: 1, b: 2, c: 3}),
      [["a", 1], ["b", 2], ["c", 3]]

  context.test "pick", ->
    assert deepEqual (pick ((k, v) -> v?), {a: 1, b: null, c: 3}),
      {a :1, c: 3}

  context.test "omit", ->
    assert deepEqual (omit ((k, v) -> v?), {a: 1, b: null, c: 3}),
      {b: null}

  context.test "query", ->
    snowWhite = name: "Snow White", dwarves: 7, enemies: [ "Evil Queen" ]
    assert query {name: "Snow White"}, snowWhite
    assert query {enemies: [ "Evil Queen" ]}, snowWhite
    assert ! query {name: "Sleeping Beauty"}, snowWhite
    assert ! query {enemies: [ "Maleficent" ]}, snowWhite

  context.test "toJSON"

  context.test "fromJSON"
