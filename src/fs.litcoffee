# File System Functions

All file-system functions are based on Node's `fs` API. This is not `require`d unless the function is actually invoked.

    fs = (f) ->
      {liftAll} = require "when/node"
      {call} = (require "when/generator")
      async = (require "when/generator").lift
      f (liftAll require "fs"), {call, async}

    {describe, assert} = require "./helpers"

    describe "File System Functions", (context) ->

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


      module.exports = {exists, read, readdir, stat, write, chdir, rm, rmdir}
