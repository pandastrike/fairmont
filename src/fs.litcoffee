# File System Functions

All file-system functions are based on Node's `fs` API. This is not `require`d unless the function is actually invoked.

    {call, async} = require "./generator"

    fs = (f) ->
      {liftAll} = require "when/node"
      f (liftAll require "fs"), {call, async}

    {describe, assert} = require "./helpers"

    describe "File system functions", (context) ->

## stat

Synchronously get the stat object for a file.

      stat = (path) -> fs ({stat}) -> stat path

      context.test "stat", ->
        assert (yield stat "test/test.json").size?

## exists

Check to see if a file exists.

      exists = exist = (path) ->
        fs ({stat}) ->
          call ->
            try
              yield stat path
              true
            catch
              false

      context.test "exists", ->
        assert (yield exists "test/test.json")
        assert !(yield exists "test/does-not-exist")


## read

Read a file and return a UTF-8 string of the contents.

      read = (path) ->
        fs ({readFile}, {call}) ->
          call -> (yield readFile path).toString()


      context.test "read", ->
        assert (JSON.parse (yield read "test/test.json")).name == "fairmont"

## readdir

Synchronously get the contents of a directory as an array.

      readdir = (path) -> fs ({readdir}) -> readdir path

      context.test "readdir", ->
        assert "test.json" in (yield readdir "test")

## read_stream

Read a stream, in its entirety, without blocking.

      read_stream = (stream) ->
        {promise} = require "when"
        buffer = ""
        promise (resolve, reject) ->
          stream.on "data", (data) -> buffer += data.toString()
          stream.on "end", -> resolve buffer
          stream.on "error", (error) -> reject error

      context.test "read_stream", ->
        do (lines) ->
          {Readable} = require "stream"
          s = new Readable
          promise = read s
          s.push "one\n"
          s.push "two\n"
          s.push "three\n"
          s.push null
          lines = (yield promise).split("\n")
          assert lines.length == 3
          assert lines[0] == "one"

## lines

Convert a stream into a line-by-line stream.

      lines = (stream) -> ((require "byline") stream)


> We might be able to provide a more general solution here based on [EventStreams][100].

[100]:https://github.com/dominictarr/event-stream


## stream

Turns a stream into an iterator function.

      stream = do ({promise, reject, resolve} = require "when") ->
        (s) ->
          do (pending = [], resolved = [], _resolve=null, _reject=null) ->
            _resolve = (x) ->
              if pending.length == 0
                resolved.push resolve x
              else
                pending.shift().resolve x
            _reject = (x) ->
              if pending.length == 0
                resolved.push reject x
              else
                pending.shift().reject x

            s.on "data", (data) -> _resolve data.toString()
            s.on "end", -> _resolve null
            s.on "error", -> _reject error

            ->
              if resolved.length == 0
                promise (resolve, reject) ->
                  pending.push {resolve, reject}
              else
                resolved.shift()

      context.test "stream", ->
        {Readable} = require "stream"
        s = new Readable
        _s = stream lines s
        s.push "one\n"
        s.push "two\n"
        s.push "three\n"
        s.push null
        assert (yield _s()) == "one"
        assert (yield _s()) == "two"
        assert (yield _s()) == "three"

## write

Synchronously write a UTF-8 string to a file.

      write = (path, content) -> fs ({writeFile}) -> writeFile path, content

      context.test "write", ->
        write "test/test.json", (yield read "test/test.json")

## chdir

Change directories, execute a function, and then restore the original working directory. The function must return a Promise.

      chdir = (dir, fn) ->
        fs ({}, {async}) ->
          cwd = process.cwd()
          process.chdir dir
          rval = yield fn()
          process.chdir cwd
          rval

      fs ({}, {async}) ->
        context.test "chdir", ->
          yield chdir "test", async ->
            assert (yield exists "test.json")
          assert ! (process.cwd().match /test$/)?

## rm

Removes a file.

      rm = (path) -> fs ({unlink}) -> unlink path

      context.test "rm"

## rmdir

Removes a directory.

      rmdir = (path) -> fs ({rmdir}) -> rmdir path

      context.test "rmdir", ->
        # test is effectively done with mkdirp test

## is_directory

      is_directory = (path) ->
        fs ({stat}, {call}) ->
          call ->
            (yield stat path).isDirectory()

      context.test "is_directory", ->
        assert (yield is_directory "./test")

## is_file

      is_file = (path) ->
        fs ({stat}, {call}) ->
          call ->
            (yield stat path).isFile()

      context.test "is_file", ->
        assert (yield is_file "./test/test.json")


## mkdir

Creates a directory. Takes a `mode` and a `path`. Assumes any intermediate directories in the path already exist.

      {curry, binary} = require "./core"
      mkdir = curry (mode, path) -> fs ({mkdir}) -> mkdir path, mode

      context.test "mdkir", ->
        yield mkdir '0777', "./test/foobar"
        assert (yield is_directory "./test/foobar")
        yield rmdir "./test/foobar"

## mkdirp

Creates a directory and any intermediate directories in the given `path`. Takes a `mode` and a `path`.

      {dirname} = require "path"
      mkdirp = curry binary async (mode, path) ->
        parent = dirname path
        if !(yield exists parent)
          yield mkdirp mode, parent
        mkdir mode, path

      context.test "mkdirp", ->
        yield mkdirp '0777', "./test/foo/bar"
        assert (yield is_directory "./test/foo/bar")
        yield rmdir "./test/foo/bar"
        yield rmdir "./test/foo"

---

      module.exports = {read, write, stream, lines, rm,
        stat, exist, exists, is_file, is_directory
        readdir, mkdir, mkdirp, chdir, rmdir}
