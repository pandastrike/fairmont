$ = {}

#
# ## String Functions ##
#

#
# ### capitalize ###
#
# Capitalize the first letter of a string.

$.capitalize = (string) ->
  string[0].toUpperCase() + string[1..]

#
# ### titleCase ###
#
# Capitalize the first letter of each word in a string.

$.titleCase = (string) ->
  string.toLowerCase().replace(/^(\w)|\W(\w)/g, (char) -> char.toUpperCase())

#
# ### camelCase ###
#
# Convert a sequence of words into a camel-cased string.
#
# ```coffee-script
# # yields fooBarBaz
# camel_case "foo bar baz"

$.camelCase = $.camel_case = (string) ->
  string.toLowerCase().replace(/(\W+\w)/g, (string) ->
    string.trim().toUpperCase())


$.underscored = (string) ->
  $.plainText(string).replace(/\W+/g, "_")

$.dashed = (string) ->
  $.plainText(string).replace(/\W+/g, "-")

$.plainText = (string) ->
  string
    .replace( /^[A-Z]/g, (c) -> c.toLowerCase() )
    .replace( /[A-Z]/g, (c) -> " #{c.toLowerCase()}" )
    .replace( /\W+/g, " " )

# Adapted from Mustache.js
$.htmlEscape = do ->

  map =
    "&": "&amp;"
    "<": "&lt;"
    ">": "&gt;"
    '"': '&quot;'
    "'": '&#39;'
    "/": '&#x2F;'

  entities = Object.keys( map )
  re = new RegExp( "#{entities.join('|')}", "g" )
  (string) -> string.replace( re, (s) -> map[s] )

module.exports = $
