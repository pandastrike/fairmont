# String Functions

    {describe, assert} = require "./helpers"

    describe "String functions", (context) ->

## to_string

      to_string = (x) -> x.toString()

### plain_text ###

Convert an camel-case or underscore- or dash-separated string into a
whitespace separated string.

      plain_text = (string) ->
        string
          .replace( /^[A-Z]/g, (c) -> c.toLowerCase() )
          .replace( /[A-Z]/g, (c) -> " #{c.toLowerCase()}" )
          .replace( /\W+/g, " " )


      context.test "plain_text", ->
        assert plain_text("hello-world") == "hello world"
        assert plain_text("Hello World") == "hello world"

## capitalize

Capitalize the first letter of a string.

      capitalize = (string) ->
        string[0].toUpperCase() + string[1..]

      context.test "capitalize", ->
        assert capitalize( "hello world" ) == "Hello world"

## title_case

Capitalize the first letter of each word in a string.

      title_case = (string) ->
        string
        .toLowerCase()
        .replace(/^(\w)|\W(\w)/g, (char) -> char.toUpperCase())


      context.test "title_case", ->
        assert title_case( "hello woRld" ) == "Hello World"

## camel_case

Convert a sequence of words into a camel-cased string.

      camel_case = (string) ->
        string.toLowerCase().replace(/(\W+\w)/g, (string) ->
          string.trim().toUpperCase())

      context.test "camel_case", ->
        assert camel_case( "Hello World" ) == "helloWorld"

## underscored

Convert a sequence of words into an underscore-separated string.

      underscored = (string) -> plain_text(string).replace(/\W+/g, "_")

      context.test "underscored", ->
        assert underscored( "Hello World" ) == "hello_world"

## dashed

Convert a sequence of words into a dash-separated string.

      dashed = (string) -> plain_text(string).replace(/\W+/g, "-")

      context.test "dashed", ->
        assert dashed( "Hello World" ) == "hello-world"

## html_escape

Escape a string so that it can be embedded into HTML. Adapted from Mustache.js.

      html_escape = do ->

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

      context.test "html_escape", ->
        assert.equal html_escape( "<a href='foo'>bar & baz</a>" ),
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

      module.exports = {to_string, capitalize, title_case, camel_case,
        underscored, dashed, plain_text, html_escape, w, blank}
