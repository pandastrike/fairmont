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
# ### title_case ###
#
# Capitalize the first letter of each word in a string.

$.titleCase = (string) ->
  string.toLowerCase().replace(/^(\w)|\W(\w)/g, (char) -> char.toUpperCase())

#
# ### camel_case ###
#
# Convert a sequence of words into a camel-cased string.
#
# ```coffee-script
# # yields fooBarBaz
# camel_case "foo bar baz"
# ```

$.camelCase = $.camel_case = (string) ->
  string.toLowerCase().replace(/(\W+\w)/g, (string) ->
    string.trim().toUpperCase())

#
# ### underscored ###
#
# Convert a sequence of words into an underscore-separated string.
#
# ```coffee-script
# # yields foo_bar_baz
# underscored "foo bar baz"
# ```

$.underscored = (string) ->
  $.plainText(string).replace(/\W+/g, "_")

#
# ### dashed ###
#
# Convert a sequence of words into a dash-separated string.
#
# ```coffee-script
# # yields foo-bar-baz
# dashed "foo bar baz"
# ```

$.dashed = (string) ->
  $.plainText(string).replace(/\W+/g, "-")

#
# ### plain_text ###
#
# Convert an camel-case or underscore- or dash-separated string into a
# whitespace separated string.
#
# ```coffee-script
# # all of the following yield foo bar baz
# plain_text "fooBarBaz"
# plain_text "foo-bar-baz"
# plain_text "foo_bar_baz"
# ```

$.plainText = $.plain_text = (string) ->
  string
    .replace( /^[A-Z]/g, (c) -> c.toLowerCase() )
    .replace( /[A-Z]/g, (c) -> " #{c.toLowerCase()}" )
    .replace( /\W+/g, " " )

#
# ### html_escape ###
#
# Escape a string so that it can be embedded into HTML. Adapted from Mustache.js.

$.htmlEscape = $.html_escape = do ->

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
