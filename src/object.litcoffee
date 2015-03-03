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
          return new Date(obj.getTime())

        if object instanceof RegExp
          flags = ''
          flags += 'g' if object.global?
          flags += 'i' if object.ignoreCase?
          flags += 'm' if object.multiline?
          flags += 'y' if object.sticky?
          return new RegExp(object.source, flags)

        clone = new object.constructor()

        for key of object
          clone[key] = ($.clone object[key])

        return clone

      context.test "clone"


## pluck

Extract a property from an object. You can extract nested properties by composing curried `pluck` invocations.

      pluck = curry (key, object) -> object[key]

      context.test "pluck", ->
        a = { foo: 1, bar: 2, baz: { foo: 2 }}
        assert (pluck "foo", a) == 1
        baz_foo = (compose (pluck "foo"), (pluck "baz"))
        assert (baz_foo a) == 2

## delegate

Delegates from one object to another by creating functions in the first object that call the second.

      delegate = (from, to) ->

        for name, value of to when (type value) is "function"
          do (value) ->
            from[name] = (args...) -> value.call to, args...

      context.test "delegate"

## liberate

Liberate a prototype function so that it can be used as a standalone function whose first argument is an instance of a prototype constructor.

      liberate = do (f=(->)) -> f.bind.bind f.call

      context.test "liberate", ->
        reverse = liberate Array::reverse
        assert deep_equal (reverse [1,2,3]), [3, 2, 1]

## properties

Define getters and setters on an object.

Properties defined using `properties` are enumerable.

      properties = property = do ->
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

      module.exports = {include, extend, merge, clone, pluck,
        property, delegate, liberate}
