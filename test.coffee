assert = require "assert"
Amen = require "amen"

# TODO: I'd like to move the tests into the Literate CoffeeScript files, since
# they naturally serve as examples of how to use the library. This file would
# then simply 'turn on' the tests so that they run. We'd provide an assert
# library wrapper that no-ops the tests unless they're turned on.
#
# I'm thinking this would work by having a few helper functions in the source
# files to set the context. These would actually add tests to Amen so that
# the output looks nice when the tests are turned on. The assert string
# would be the name of the test.


Fairmont = require "./src/index"

Amen.describe "Fairmont", (context) ->

  context.test "FP functions", (context) ->

    context.test "liberate", ->
      {liberate} = Fairmont
      reverse = liberate Array::reverse
      assert.deepEqual (reverse [1,2,3]), [3, 2, 1]

    context.test "curry", ->
      {curry} = Fairmont
      add = curry (x, y) -> x + y
      assert ((add 1, 2) == 3)
      assert (((add 3) 4) == 7)

    context.test "partial", ->
      {partial} = Fairmont
      sum = (ax...) -> ax.reduce ((sum, x) -> sum += x), 0
      sum5 = partial sum, 5
      assert (sum5 8) == 13

    context.test "partial with substition", ->
      {partial, _} = Fairmont
      {pow} = Math
      square = partial pow, _, 2
      assert (square 3) == 9

    context.test "flip with 2 arguments", ->
      {curry, flip} = Fairmont
      {pow} = Math
      square =  (curry flip pow)(2)
      assert (square 3) == 9

    context.test "flip with 3 arguments"

    context.test "flip with N arguments"

    context.test "flip with no arguments"

    context.test "flip with variable arguments"

    context.test "compose functions", ->
      {compose} = Fairmont
      data = foo: 1, bar: 2, baz: 3
      {parse, stringify} = JSON
      clone = compose parse, stringify
      assert.deepEqual (clone data), data

    context.test "pipe functions", ->
      {pipe} = Fairmont
      data = foo: 1, bar: 2, baz: 3
      {parse, stringify} = JSON
      clone = pipe stringify, parse
      assert.deepEqual (clone data), data


  context. test "String functions", (context) ->

    {capitalize, title_case, camel_case, underscored,
      dashed, plain_text, html_escape} = require "./src/index"

    context.test "capitalize", ->
      assert capitalize( "hello world" ) == "Hello world"

    context.test "title_case", ->
      assert title_case( "hello woRld" ) == "Hello World"

    context.test "underscored", ->
      assert underscored( "Hello World" ) == "hello_world"

    context.test "camel_case", ->
      assert camel_case( "Hello World" ) == "helloWorld"

    context.test "dashed", ->
      assert dashed( "Hello World" ) == "hello-world"

    context.test "plain_text", ->
      assert plain_text("hello-world") == "hello world"
      assert plain_text("Hello World") == "hello world"

    context.test "html_escape", ->
      assert.equal html_escape( "<a href='foo'>bar & baz</a>" ),
        "&lt;a href=&#39;foo&#39;&gt;bar &amp; baz&lt;&#x2F;a&gt;"

  context.test "Array functions", (context) ->
    {fold, unique, dupes, flatten, shuffle} = require "./src/index"

    context.test "fold", ->
      data = [1, 2, 3, 4, 5]
      fn = fold 1, (acc, x) -> acc += x
      assert.deepEqual (fn data), 16

    context.test "unique", ->
      {unique} = Fairmont
      data = [1, 2, 1, 3, 5, 3, 6]
      assert.deepEqual (unique data), [1, 2, 3, 5, 6]

    context.test "dupes", ->
      {dupes} = Fairmont
      data = [1, 2, 1, 3, 5, 3, 6]
      assert.deepEqual (dupes data), [1, 3]

    context.test "flatten", ->
      {flatten} = Fairmont
      data = [1, [2, 3], 4, [5, [6, 7]]]
      assert.deepEqual (flatten data), [1..7]

    context.test "shuffle", ->
      {shuffle} = Fairmont
      data = ["a", "b", "c", "d", "e", "f"]
      assert.notDeepEqual (shuffle data), data


  context.test "File system functions", (context) ->
    {read, readdir, stat} = require "./src/fs"

    context.test "Read a file", ->
      assert (JSON.parse (yield read "package.json")).name == "fairmont"

    context.test "Read a directory", ->
      assert "package.json" in (yield readdir ".")

    context.test "Stat a file", ->
      assert (yield stat "package.json").size?
