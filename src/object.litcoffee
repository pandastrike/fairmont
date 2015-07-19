# Object Functions

    {compose, curry, deepEqual} = require "./core"

## include, extend

Adds the properties of one or more objects to another. Aliased as `extend`.

    include = extend = (object, mixins...) ->
      for mixin in mixins
        for key, value of mixin
          object[key] = value
      object

## merge

Creates new object by progressively adding the properties of each given object.

    merge = (objects...) ->

      destination = {}
      for object in objects
        destination[k] = v for k, v of object
      destination

## clone

Perform a deep clone on an object. Taken from [The CoffeeScript Cookboox][0].

[0]:http://coffeescriptcookbook.com/chapters/classesAndObjects/cloning

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

## property

Extract a property from an object. You can extract nested properties by composing curried `property` invocations.

    property = curry (key, object) -> object[key]

## delegate

Delegates from one object to another by creating functions in the first object that call the second.

    delegate = (from, to) ->

      for name, value of to when (type value) is "function"
        do (value) ->
          from[name] = (args...) -> value.call to, args...

## bind

Define a function based on a prototype function and an instance of the prototype. **Important** In the past, this did not always work for some natively implemented functions. That is hopefully no longer the case.

    bind = curry (f, x) -> f.bind x

## detach

Define a function based on a prototype function, taking as its first argument an instance of prototype. **Important** In the past, this did not always work for some natively implemented functions. That is hopefully no longer the case.

    detach = (f) -> curry (x, args...) -> f.apply x, args

## properties

Define getters and setters on an object.

Properties defined using `properties` are enumerable.

    properties = do ->
      defaults = enumerable: true, configurable: true
      (object, properties) ->
        for key, value of properties
          include value, defaults
          Object.defineProperty object, key, value

## has

Check if an object has a property.

    has = curry (p, x) -> x[p]?

## keys

Get the keys for an object.

    keys = Object.keys

## values

Get the values for an object.

    values = (x) -> v for k, v of x

## pairs

Convert an object into association array.

    pairs = (x) -> [k, v] for k, v of x

## pick

    pick = (f, x) ->
      r = {}
      r[k] = v for k, v of x when f k, v
      r

## omit

    {negate} = require "./logical"
    omit = (f, x) -> pick (negate f), x

## query

    {isObject} = require "./type"
    query = curry (example, target) ->
      if (isObject example) && (isObject target)
        for k, v of example
          return false unless query v, target[k]
        return true
      else
        deepEqual example, target

## toJSON, fromJSON

    toJSON = (x, pretty = false) ->
      if pretty
        JSON.stringify x, null, 2
      else
        JSON.stringify x

    fromJSON = JSON.parse

---

    module.exports = {include, extend, merge, clone,
      properties, property, delegate, bind, detach,
      has, keys, values, pairs, pick, omit, query,
      toJSON, fromJSON}
