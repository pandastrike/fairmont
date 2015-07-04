# String Functions

    {describe, assert} = require "./helpers"

    describe "String functions", (context) ->

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


      context.test "plainText", ->
        assert plainText("hello-world") == "hello world"
        assert plainText("Hello World") == "hello world"

## capitalize

Capitalize the first letter of a string.

      capitalize = (string) ->
        string[0].toUpperCase() + string[1..]

      context.test "capitalize", ->
        assert capitalize( "hello world" ) == "Hello world"

## titleCase

Capitalize the first letter of each word in a string.

      titleCase = (string) ->
        string
        .toLowerCase()
        .replace(/^(\w)|\W(\w)/g, (char) -> char.toUpperCase())


      context.test "titleCase", ->
        assert titleCase( "hello woRld" ) == "Hello World"

## camelCase

Convert a sequence of words into a camel-cased string.

      camelCase = (string) ->
        string.toLowerCase().replace(/(\W+\w)/g, (string) ->
          string.trim().toUpperCase())

      context.test "camelCase", ->
        assert camelCase( "Hello World" ) == "helloWorld"

## underscored

Convert a sequence of words into an underscore-separated string.

      underscored = (string) -> plainText(string).replace(/\W+/g, "_")

      context.test "underscored", ->
        assert underscored( "Hello World" ) == "helloWorld"

## dashed

Convert a sequence of words into a dash-separated string.

      dashed = (string) -> plainText(string).replace(/\W+/g, "-")

      context.test "dashed", ->
        assert dashed( "Hello World" ) == "hello-world"

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

      context.test "htmlEscape", ->
        assert.equal htmlEscape( "<a href='foo'>bar & baz</a>" ),
          "&lt;a href=&#39;foo&#39;&gt;bar &amp; baz&lt;&#x2F;a&gt;"


## w

Split a string on whitespace. Useful for concisely creating arrays of strings.

      w = (string) -> string.trim().split /\s+/

      context.test "w", -> assert (w "one two three").length == 3

## blank

Check to see if a string has zero length.

      blank = (s) -> s.length == 0

      context.test "blank", ->
        assert blank ""
        assert !blank "x"

---

      module.exports = {toString, toUpper, toLower, capitalize,
        titleCase, camelCase, underscored, dashed, plainText,
        htmlEscape, w, blank}
