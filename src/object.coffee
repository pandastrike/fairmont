$ = {}

$.include = include = (object, mixins...) ->
  for mixin in mixins
    for key, value of mixin
      object[key] = value
  object

# Shallow merge
$.merge = (objects...) ->

  destination = {}
  for object in objects
    destination[k] = v for k, v of object
  destination

module.exports = $
