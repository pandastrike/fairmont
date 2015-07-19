assert = require "assert"
Amen = require "amen"

Amen.describe "String functions", (context) ->

  {toString, toUpper, toLower, capitalize,
    titleCase, camelCase, underscored, dashed, plainText,
    htmlEscape, w, blank} = require "../src/string"

  context.test "toString"
  context.test "toUpper"
  context.test "toLower"

  context.test "plainText", ->
    assert plainText("hello-world") == "hello world"
    assert plainText("Hello World") == "hello world"

  context.test "capitalize", ->
    assert capitalize( "hello world" ) == "Hello world"

  context.test "titleCase", ->
    assert titleCase( "hello woRld" ) == "Hello World"

  context.test "camelCase", ->
    assert camelCase( "Hello World" ) == "helloWorld"

  context.test "underscored", ->
    assert underscored( "Hello World" ) == "hello_world"

  context.test "dashed", ->
    assert dashed( "Hello World" ) == "hello-world"

  context.test "htmlEscape", ->
    assert htmlEscape( "<a href='foo'>bar & baz</a>" ) ==
      "&lt;a href=&#39;foo&#39;&gt;bar &amp; baz&lt;&#x2F;a&gt;"

  context.test "w", -> assert (w "one two three").length == 3

  context.test "blank", ->
    assert blank ""
    assert !blank "x"
