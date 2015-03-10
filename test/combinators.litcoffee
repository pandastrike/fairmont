# Combinators, FTW

Let's load up some goodies.

    {curry, binary, wrap, compose, read, readdir,
      md5, collect, map, assoc, zip, async, call} =
      require "../src/index"

We're going to make some assertions.

    assert = require "assert"

We need the `join` and `resolve` functions from path

    {join, resolve} = do ({join, resolve} = require "path")->
      {join: (curry binary join), resolve}

`content_map` is our function.

    content_map = async (path) ->
      paths = collect map (compose resolve, join path), yield readdir path
      assoc zip (map (compose md5, read), paths), paths

Let's test it out.

    call ->
      assert  (yield content_map "./test")["deed54b823522e0525693b090363f9df"]?
