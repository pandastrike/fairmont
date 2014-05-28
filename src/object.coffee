$ = {}
type = require "./type"

#
# ## Object Functions
#

#
# ### include ###
#
# Adds the properties of one or more objects to another.
#
# ```coffee-script
# include( @, ScrollbarMixin, SidebarMixin )
# ```

$.include = include = (object, mixins...) ->
  for mixin in mixins
    for key, value of mixin
      object[key] = value
  object

#
# ### Property ###
#
# Add a `property` method to a class, making it easier to define getters and setters on its prototype.
#
# ```coffee-script
# class Foo
#   include @, Property
#   property "foo", get: -> @_foo, set: (v) -> @_foo = v
# ```
#
# Properties defined using `property` are enumerable.

$.Property =

  property: do ->
    defaults = enumerable: true, configurable: true
    (properties) ->
      for key, value of properties
        include value, defaults
        Object.defineProperty @::, key, value

#
# ### delegate ###
#
# Delegates from one object to another by creating functions in the first object that call the second.
#
# ```coffee-script
# delegate( aProxy, aServer )
# ```

$.delegate = (from, to) ->

  for name, value of to when (type value) is "function"
    do (value) ->
      from[name] = (args...) -> value.call to, args...

#
# ### merge ###
#
# Creates new object by progressively adding the properties of each given object.
#
# ```coffee-script
# options = merge( defaults, globalOptions, localOptions )
# ```

$.merge = (objects...) ->

  destination = {}
  for object in objects
    destination[k] = v for k, v of object
  destination

#
# ### clone ###
#
# Perform a deep clone on an object. Taken from [The CoffeeScript Cookboox][clone-1].
#
# [clone-1]:http://coffeescriptcookbook.com/chapters/classes_and_objects/cloning
#
# ```coffee-script
# copy = clone original
# ```

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
