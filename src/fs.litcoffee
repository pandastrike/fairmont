# File System Functions

    {async} = require "./generator"

    {describe, assert} = require "./helpers"

    describe "File system functions", (context) ->

      {liftAll} = require "when/node"
      FS = (liftAll require "fs")

## stat

Synchronously get the stat object for a file.

      stat = (path) -> FS.stat path

      context.test "stat", ->
        assert (yield stat "test/test.json").size?

## exists

Check to see if a file exists.

      exists = exist = async (path) ->
        try
          yield FS.stat path
          true
        catch
          false

      context.test "exists", ->
        assert (yield exists "test/test.json")
        assert !(yield exists "test/does-not-exist")

## read

Read a file and return a UTF-8 string of the contents.

      {Method} = require "./multimethods"

      read = Method.create()

      Method.define read, String, String, (path, encoding) ->
        FS.readFile path, encoding

      Method.define read, String, (path) -> read path, 'utf8'

Passing an explicit 'null'/`undefined` or 'binary'/'buffer' as the encoding will return the raw buffer.

      Method.define read, String, undefined, (path) -> FS.readFile path
      Method.define read, String, "binary", (path) -> FS.readFile path
      Method.define read, String, "buffer", (path) -> FS.readFile path

You can also just pass in a readable stream.

      stream = require "stream"
      {promise} = require "when"
      Method.define read, stream.Readable, (stream) ->
        buffer = ""
        promise (resolve, reject) ->
          stream.on "data", (data) -> buffer += data.toString()
          stream.on "end", -> resolve buffer
          stream.on "error", (error) -> reject error

      context.test "read", ->
      assert (yield read "test/lines.txt") == "one\ntwo\nthree\n"

      context.test "read buffer", ->
        assert (yield read "test/lines.txt", "binary").constructor == Buffer

      context.test "read stream", ->
        {createReadStream} = require "fs"
        s = createReadStream "test/lines.txt"
        assert (yield read s) == "one\ntwo\nthree\n"


## readDir

Get the contents of a directory as an array.

      readdir = readDir = (path) -> FS.readdir path

      context.test "readdir", ->
        assert "test.json" in (yield readdir "test")

## ls

Get the contents of a directory as an array of pathnames.

      ls = async (path) ->
        (join path, file) for file in (yield readdir path)

## lsR

Recursively get the contents of a directory as an array.

      {flatten} = require "./iterator"
      {join} = require "path"
      lsR = async (path, visited = []) ->
        for childPath in (yield ls path)
          if !(childPath in visited)
            info = yield FS.lstat childPath
            if info.isDirectory()
              yield lsR childPath, visited
            else
              visited.push childPath
        visited

      context.test "lsR", ->
        {resolve} = require "path"
        testDir = join __dirname, ".."
        assert (join testDir, "test/test.json") in (yield lsR testDir)

## glob

Glob a directory.

      {Minimatch} = require "minimatch"
      glob = async (pattern, path) ->
        minimatch = new Minimatch pattern
        match = (path) ->
          minimatch.match path
        _path for _path in (yield lsR path) when match _path

      context.test "glob", ->
        testDir = join __dirname, ".."
        assert ((join testDir, "test", "test.litcoffee") in
          (yield glob "**/*.litcoffee", testDir))

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

Synchronously write a UTF-8 string or data buffer to a file.

      write = (path, content) -> FS.writeFile path, content

      context.test "write", ->
        write "test/test.json", (yield read "test/test.json")

## chdir

Change directories, execute a function, and then restore the original working directory. The function must return a Promise.

      chdir = (dir, fn) ->
        cwd = process.cwd()
        process.chdir dir
        fn()
        process.chdir cwd

      context.test "chdir", ->
        cwd = process.cwd()
        chdir "test", ->
          fs = require "fs"
          assert (fs.statSync "test.json").size?
        assert cwd == process.cwd()

## rm

Removes a file.

      rm = async (path) -> FS.unlink path

      context.test "rm"

## rmdir

Removes a directory.

      rmdir = (path) -> FS.rmdir path

      context.test "rmdir", ->
        # test is effectively done with mkdirp test

## isDirectory

      isDirectory = async (path) -> (yield stat path).isDirectory()

      context.test "isDirectory", ->
        assert (yield isDirectory "./test")

## isFile

      isFile = async (path) -> (yield stat path).isFile()

      context.test "isFile", ->
        assert (yield isFile "./test/test.json")

## mkdir

Creates a directory. Takes a `mode` and a `path`. Assumes any intermediate directories in the path already exist.

      {curry, binary} = require "./core"
      mkdir = curry binary (mode, path) -> FS.mkdir path, mode

      context.test "mdkir", ->
        yield mkdir '0777', "./test/foobar"
        assert (yield isDirectory "./test/foobar")
        yield rmdir "./test/foobar"

## mkdirp

Creates a directory and any intermediate directories in the given `path`. Takes a `mode` and a `path`.

      {dirname} = require "path"
      {curry, binary} = require "./core"
      mkdirp = curry binary async (mode, path) ->
        if !(yield exists path)
          parent = dirname path
          if !(yield exists parent)
            yield mkdirp mode, parent
          mkdir mode, path

      context.test "mkdirp", ->
        yield mkdirp '0777', "./test/foo/bar"
        assert (yield isDirectory "./test/foo/bar")
        yield rmdir "./test/foo/bar"
        yield rmdir "./test/foo"

---

      module.exports = {read, write, stream, lines, rm,
        stat, exist, exists, isFile, isDirectory, readdir, readDir,
        ls, lsR, mkdir, mkdirp, chdir, rmdir}
