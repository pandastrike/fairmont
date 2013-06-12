assert = require "assert"
Testify = require "testify"

Testify.test "String functions", (context) ->
  context.test "capitalize", ->
    {capitalize} = require "./index"
    assert.equal capitalize( "hello world" ), "Hello world"
  context.test "titleCase", ->
    {titleCase} = require "./index"
    assert.equal titleCase( "hello woRld" ), "Hello World"
  context.test "snakeCase", ->
    {snakeCase} = require "./index"
    assert.equal snakeCase( "Hello World" ), "hello_world"
  context.test "camelCase", ->
    {camelCase} = require "./index"
    assert.equal camelCase( "Hello World" ), "helloWorld"
  context.test "corsetCase", ->
    {corsetCase} = require "./index"
    assert.equal corsetCase( "Hello World" ), "hello-world"
  context.test "htmlEscape", ->
    {htmlEscape} = require "./index"
    assert.equal htmlEscape( "<a href='foo'>bar & baz</a>" ), 
      "&lt;a href=&#39;foo&#39;&gt;bar &amp; baz&lt;&#x2F;a&gt;"
  