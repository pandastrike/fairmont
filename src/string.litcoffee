# String Functions

## toString

    toString = (x) -> x.toString()

## toUpper

    toUpper = (s) -> s.toUpperCase()

## toLower

    toLower = (s) -> s.toLowerCase()

## plainText

Convert an camel-case or underscore- or dash-separated string into a
whitespace separated string.

    plainText = (string) ->
      string
        .replace( /^[A-Z]/g, (c) -> c.toLowerCase() )
        .replace( /[A-Z]/g, (c) -> " #{c.toLowerCase()}" )
        .replace( /\W+/g, " " )

## capitalize

Capitalize the first letter of a string.

    capitalize = (string) ->
      string[0].toUpperCase() + string[1..]

## titleCase

Capitalize the first letter of each word in a string.

    titleCase = (string) ->
      string
      .toLowerCase()
      .replace(/^(\w)|\W(\w)/g, (char) -> char.toUpperCase())

## camelCase

Convert a sequence of words into a camel-cased string.

    camelCase = (string) ->
      string.toLowerCase().replace(/(\W+\w)/g, (string) ->
        string.trim().toUpperCase())

## underscored

Convert a sequence of words into an underscore-separated string.

    underscored = (string) -> plainText(string).replace(/\W+/g, "_")

## dashed

Convert a sequence of words into a dash-separated string.

    dashed = (string) -> plainText(string).replace(/\W+/g, "-")

## htmlEscape

Escape a string so that it can be embedded into HTML. Adapted from Mustache.js.

    htmlEscape = do ->

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

## w

Split a string on whitespace. Useful for concisely creating arrays of strings.

    w = (string) -> string.trim().split /\s+/

## blank

Check to see if a string has zero length.

    blank = (s) -> s.length == 0

---

    module.exports = {toString, toUpper, toLower, capitalize,
      titleCase, camelCase, underscored, dashed, plainText,
      htmlEscape, w, blank}
