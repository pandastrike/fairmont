$ = {}

# Given a string, return an array containing the substrings
# found separated by whitespace. Like Ruby's %w[] syntax.
$.w = w = (string) -> string.trim().split /\s+/

# Mixins

for m in $.w "string array fs crypto object"
  exports = require "./src/#{m}"
  for key, fn of exports
    $[key] = fn


# Direct requires

$.type = require "./src/type"
$.assert = require "./src/assert"


# Direct definitions

$.to = (to, from) ->
  if from instanceof to then from else new to from


$.abort = -> process.exit -1

# Very simplistic memoize - only works for one argument
# where toString is a unique value

$.memoize = (fn, hash=(object)-> object.toString()) ->
  memo = {}
  (thing) -> memo[ hash( thing ) ] ?= fn(thing)

$.timer = (wait, action) ->
  id = setTimeout(action, wait)
  -> clearTimeout( id )

module.exports = $
