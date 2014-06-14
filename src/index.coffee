$ = {}

#
# ## General Purpose Functions ##
#

# ### w ###
#
# Split a string on whitespace. Useful for concisely creating arrays of strings.
#
# ```coffee-script
# console.log word for word in w "foo bar baz"
# ```

$.w = (string) -> string.trim().split /\s+/

# ### to ###
#
# Hoist a value to a given type if it isn't already. Useful when you want to wrap a value without having to check to see if it's already wrapped.
#
# For example, to hoist an error message into an error, you would use:
#
# ```coffee-script
# to(error, Error)
# ```

$.to = (to, from) ->
  if from instanceof to then from else new to from

# ### abort ###
#
# Simple wrapper around `process.exit(-1)`.

$.abort = -> process.exit -1

#
# ### memoize ###
#
# A very simple way to cache results of functions that take a single argument. Also takes an optional hash function that defaults to calling `toString` on the function's argument.
#
# ```coffee-script
# nickname = (email) ->
#   expensiveLookupToGetNickname( email )
#
# memoize( nickname )
# ```

$.memoize = (fn, hash=(object)-> object.toString()) ->
  memo = {}
  (thing) -> memo[ hash( thing ) ] ?= fn(thing)

#
### timer ###
#
# Set a timer. Takes an interval in microseconds and an action. Returns a function to cancel the timer. Basically, a more convenient way to call `setTimeout` and `clearTimeout`.
#
# ```coffee-script
# cancel = timer 1000, -> console.log "Done"
# cancel()
# ```

$.timer = (wait, action) ->
  id = setTimeout(action, wait)
  -> clearTimeout( id )

# -- load the rest of the functions

{basename} = require "path"
{readdir} = require "./fs"
{include} = require "./object"

for filename in readdir(__dirname)
  _module = basename(filename, ".coffee")
  if _module != "index"
    try
      include $, require("./#{_module}")
    catch error


module.exports = $
