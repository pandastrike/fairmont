assert = require "assert"
Testify = require "testify"

Fairmont = require "./index"

Testify.test "String functions", (context) ->
  context.test "capitalize", ->
    {capitalize} = Fairmont
    assert.equal capitalize( "hello world" ), "Hello world"

  context.test "titleCase", ->
    {titleCase} = Fairmont
    assert.equal titleCase( "hello woRld" ), "Hello World"

  context.test "underscored", ->
    {underscored} = Fairmont
    assert.equal underscored( "Hello World" ), "hello_world"

  context.test "camelCase", ->
    {camelCase} = Fairmont
    assert.equal camelCase( "Hello World" ), "helloWorld"

  context.test "dashed", ->
    {dashed} = Fairmont
    assert.equal dashed( "Hello World" ), "hello-world"

  context.test "plainText", ->
    {plainText} = Fairmont
    assert.equal plainText("hello-world"), "hello world"
    assert.equal plainText("Hello World"), "hello world"

  context.test "htmlEscape", ->
    {htmlEscape} = Fairmont
    assert.equal htmlEscape( "<a href='foo'>bar & baz</a>" ), 
      "&lt;a href=&#39;foo&#39;&gt;bar &amp; baz&lt;&#x2F;a&gt;"
  
