# File System Functions

All file-system functions are based on Node's `fs` API. This is not `require`d unless the `fs` function is actually invoked.

    {async} = require "./generator"

    FS = undefined
    initFS = ->
      FS ?= do ->
        {liftAll} = require "when/node"
        (liftAll require "fs")

    init = (f) ->
      (ax...) ->
        initFS()
        f ax...

    {describe, assert} = require "./helpers"

    describe "File system functions", (context) ->

## stat

Synchronously get the stat object for a file.

      stat = init (path) -> FS.stat path

      context.test "stat", ->
        assert (yield stat "test/test.json").size?

## exists

Check to see if a file exists.

      exists = exist = init async (path) ->
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

      read = init async (path, encoding = 'utf8') ->
        yield FS.readFile path, encoding

      context.test "read", ->
        assert (JSON.parse (yield read "test/test.json")).name == "fairmont"

## readBuffer

Read a file and return the raw buffer.

      readBuffer = init async (path) -> yield FS.readFile path

      context.test "readBuffer", ->
        assert (yield readBuffer "test/test.json").constructor == Buffer

## readdir

Get the contents of a directory as an array.

      readdir = init (path) -> FS.readdir path

      context.test "readdir", ->
        assert "test.json" in (yield readdir "test")

## ls

Get the contents of a directory as an array of pathnames.

      ls = init async (path) ->
        (join path, file) for file in (yield readdir path)

## lsR

Recursively get the contents of a directory as an array.

      {flatten} = require "./iterator"
      {join} = require "path"
      lsR = init async (path, visited = []) ->
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
      glob = init async (pattern, path) ->
        minimatch = new Minimatch pattern
        match = (path) ->
          minimatch.match path
        _path for _path in (yield lsR path) when match _path

      context.test "glob", ->
        testDir = join __dirname, ".."
        assert ((join testDir, "test", "test.litcoffee") in
          (yield glob "**/*.litcoffee", testDir))

## readStream

Read a stream, in its entirety, without blocking.

      readStream = (stream) ->
        {promise} = require "when"
        buffer = ""
        promise (resolve, reject) ->
          stream.on "data", (data) -> buffer += data.toString()
          stream.on "end", -> resolve buffer
          stream.on "error", (error) -> reject error

      context.test "readStream", ->
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

Synchronously write a UTF-8 string or data buffer to a file.

      write = init (path, content) -> FS.writeFile path, content

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

      rm = init async (path) -> FS.unlink path

      context.test "rm"

## rmdir

Removes a directory.

      rmdir = init (path) -> FS.rmdir path

      context.test "rmdir", ->
        # test is effectively done with mkdirp test

## isDirectory

      isDirectory = init async (path) -> (yield stat path).isDirectory()

      context.test "isDirectory", ->
        assert (yield isDirectory "./test")

## isFile

      isFile = init async (path) -> (yield stat path).isFile()

      context.test "isFile", ->
        assert (yield isFile "./test/test.json")

## mkdir

Creates a directory. Takes a `mode` and a `path`. Assumes any intermediate directories in the path already exist.

      {curry, binary} = require "./core"
      mkdir = curry binary init (mode, path) -> FS.mkdir path, mode

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

      module.exports = {read, readBuffer, write, stream, lines, rm,
        stat, exist, exists, isFile, isDirectory
        readdir, ls, lsR, mkdir, mkdirp, chdir, rmdir}
