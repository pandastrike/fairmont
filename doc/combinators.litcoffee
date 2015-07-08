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

A very nice feature of Fairmont's compose is that it doesn't require the use of `yield` unless you've composed an asynchronous function.

    {sub, abs} = require "../src/index"
    delta = compose abs, sub
    assert (delta 5, 7) == 2

Yet I can still compose, say, `read` and `md5`.

    hash_file = compose md5, read

    call ->
      yield hash_file "test/lines.txt"

Let's filter vowels from strings.

    {partial, includes, _, w, fold, select, add} = require "../src/index"

    is_vowel = partial includes, _, (w "a e i o u")
    consonants = select is_vowel
    stringify = fold "", add
    assert (stringify consonants "panama") == "aaa"
