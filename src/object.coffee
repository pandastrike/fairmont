$ = {}
type = require "./type"

$.include = include = (object, mixins...) ->
  for mixin in mixins
    for key, value of mixin
      object[key] = value
  object


# Convenient way to define properties
#
#   class Foo
#
#     include @, Property
#
#     property foo: get: -> "foo"
#
$.Property =

  property: do ->
    defaults = enumerable: true, configurable: true
    (properties) ->
      for key, value of properties
        include value, defaults
        Object.defineProperty @::, key, value


$.delegate = (from, to) ->

  for name, value of to when (type value) is "function"
    do (value) ->
      from[name] = (args...) -> value.call to, args...


# Shallow merge
$.merge = (objects...) ->

  destination = {}
  for object in objects
    destination[k] = v for k, v of object
  destination

$.clone = (object) ->

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

module.exports = $
