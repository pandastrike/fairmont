# Object Functions

    {describe, assert} = require "./helpers"
    {compose, curry} = require "./core"
    {deep_equal} = require "./type"

    describe "Object functions", (context) ->

## include, extend

Adds the properties of one or more objects to another. Aliased as `extend`.

      include = extend = (object, mixins...) ->
        for mixin in mixins
          for key, value of mixin
            object[key] = value
        object

      context.test "include"


## merge

Creates new object by progressively adding the properties of each given object.

      merge = (objects...) ->

        destination = {}
        for object in objects
          destination[k] = v for k, v of object
        destination

      context.test "merge"

## clone

Perform a deep clone on an object. Taken from [The CoffeeScript Cookboox][0].

[0]:http://coffeescriptcookbook.com/chapters/classes_and_objects/cloning

      clone = (object) ->

        if not object? or typeof object isnt 'object'
          return object

        if object instanceof Date
          return new Date(object.getTime())

        if object instanceof RegExp
          flags = ''
          flags += 'g' if object.global?
          flags += 'i' if object.ignoreCase?
          flags += 'm' if object.multiline?
          flags += 'y' if object.sticky?
          return new RegExp(object.source, flags)

        _clone = new object.constructor()

        for key of object
          _clone[key] = (clone object[key])

        return _clone

      context.test "clone", ->
        is_clone = (original, copy) ->
          assert.notEqual  original, copy
          assert.deepEqual original, copy

        person =
          name: "Steve Jobs"
          address:
            street: "1 Infinite Loop"
            city: "Cupertino, CA"
            zip: 95014
          birthdate: new Date 'Feb 24, 1955'
          regex: /foo.*/igm

        is_clone person, clone person

## property

Extract a property from an object. You can extract nested properties by composing curried `property` invocations.

      property = curry (key, object) -> object[key]

      context.test "property", ->
        a = { foo: 1, bar: 2, baz: { foo: 2 }}
        assert (property "foo", a) == 1
        baz_foo = (compose (property "foo"), (property "baz"))
        assert (baz_foo a) == 2

## delegate

Delegates from one object to another by creating functions in the first object that call the second.

      delegate = (from, to) ->

        for name, value of to when (type value) is "function"
          do (value) ->
            from[name] = (args...) -> value.call to, args...

      context.test "delegate"

## bind

Define a function based on a prototype function and an instance of the prototype. **Important** In the past, this did not always work for some natively implemented functions. That is hopefully no longer the case.

      bind = curry (f, x) -> f.bind x

      context.test "bind", ->
        trim = bind String::trim, "foo "
        assert (trim()), "foo"

## detach

Define a function based on a prototype function, taking as its first argument an instance of prototype. **Important** In the past, this did not always work for some natively implemented functions. That is hopefully no longer the case.

      detach = (f) -> curry (x, args...) -> f.apply x, args

      context.test "detach", ->
        trim = detach String::trim
        assert (trim "foo "), "foo"

## properties

Define getters and setters on an object.

Properties defined using `properties` are enumerable.

      properties = do ->
        defaults = enumerable: true, configurable: true
        (object, properties) ->
          for key, value of properties
            include value, defaults
            Object.defineProperty object, key, value

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

---

      module.exports = {include, extend, merge, clone,
        properties, property, delegate, bind, detach}
