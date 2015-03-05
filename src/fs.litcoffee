# File System Functions

All file-system functions are based on Node's `fs` API. This is not `require`d unless the function is actually invoked.

    fs = (f) ->
      {liftAll} = require "when/node"
      {call} = (require "when/generator")
      async = (require "when/generator").lift
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

      exists = stat

      context.test "exists", ->
        (yield exists "test/test.json")
        assert (yield exists "test/test.json")


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
          stream = new Readable
          promise = read stream
          stream.push "one\n"
          stream.push "two\n"
          stream.push "three\n"
          stream.push null
          lines = (yield promise).split("\n")
          assert lines.length == 3
          assert lines[0] == "one"

## lines

Convert a stream into a line-by-line stream.

      lines = (stream) -> ((require "byline") stream)


> We might be able to provide a more general solution here based on [EventStreams][100].

[100]:https://github.com/dominictarr/event-stream


## read_block

Read a chunk of data from a stream without blocking. Returns a function that will return a promise for the next block and can be called repeatedly. **Important** This should probably be generator function, except that I haven't quite decided how to integrate the object-oriented nature of Iterators with the FP approach we're trying to use here. **Also** I'd ideally like to simplify this function somehow.

      read_block = do ({promise, reject, resolve} = require "when") ->
        (stream) ->
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

            stream.on "data", (data) -> _resolve data.toString()
            stream.on "end", -> _resolve null
            stream.on "error", -> _reject error

            ->
              if resolved.length == 0
                promise (resolve, reject) ->
                  pending.push {resolve, reject}
              else
                resolved.shift()



      context.test "read_block", ->
        {Readable} = require "stream"
        do (stream = new Readable) ->
          stream.push "one\n"
          stream.push "two\n"
          stream.push "three\n"
          _stream = lines stream
          assert (yield read_block _stream) == "one"
          assert (yield read_block _stream) == "two"
          assert (yield read_block _stream) == "three"

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

      rm = (path) -> fs({unlink}) -> unlink path

      context.test "rm"

## rmdir

Removes a directory.

      rmdir = (path) -> fs({rmdir}) -> rmdir path

      context.test "rmdir"

---


      module.exports = {exists, read, read_stream, lines, read_block,
        readdir, stat, write, chdir, rm, rmdir}
