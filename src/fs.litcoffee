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
        assert (yield stat "test/lines.txt").size?

## exists

Check to see if a file exists.

      exists = exist = async (path) ->
        try
          yield FS.stat path
          true
        catch
          false

      context.test "exists", ->
        assert (yield exists "test/lines.txt")
        assert !(yield exists "test/does-not-exist")

## read

Read a file and return a UTF-8 string of the contents.

      {Method} = require "./multimethods"

      read = Method.create()

      Method.define read, String, String, (path, encoding) ->
        FS.readFile path, encoding

      Method.define read, String, (path) -> read path, 'utf8'

Passing an explicit 'null'/`undefined` or 'binary'/'buffer' as the encoding will return the raw buffer.

      readBuffer = (path) -> FS.readFile path
      Method.define read, String, undefined, readBuffer
      Method.define read, String, "binary", readBuffer
      Method.define read, String, "buffer", readBuffer

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


## readDir / readdir

Get the contents of a directory as an array.

      readdir = readDir = (path) -> FS.readdir path

      context.test "readdir", ->
        assert "lines.txt" in (yield readdir "test")

## ls

Get the contents of a directory as an array of pathnames.

      ls = async (path) ->
        (join path, file) for file in (yield readdir path)

## lsR / lsr

Recursively get the contents of a directory as an array.

      {flatten} = require "./iterator"
      {join} = require "path"
      lsR = lsr = async (path, visited = []) ->
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
        assert (join testDir, "test/lines.txt") in (yield lsR testDir)

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

## write

Synchronously write a UTF-8 string or data buffer to a file.

      write = (path, content) -> FS.writeFile path, content

      context.test "write", ->
        write "test/lines.txt", (yield read "test/lines.txt")

## chDir / chdir

Change directories. If a function is passed in execute the function, and restore the original working directory. Otherwise, returns a function to restore the original working directory. **Important** Do not rely on the automatic restoration feature when using asynchronous functions, since another function may also change the current directory.

      {Method} = require "./multimethods"

      chDir = chdir = Method.create()

      Method.define chdir, String, (path) ->
        cwd = process.cwd()
        process.chdir path
        -> process.chdir cwd

      Method.define chdir, String, Function, (path, f) ->
        restore = chdir path
        f()
        restore()

      context.test "chdir", ->
        cwd = process.cwd()
        chDir "test", ->
          fs = require "fs"
          assert (fs.statSync "lines.txt").size?
        assert cwd == process.cwd()

## rm

Removes a file.

      rm = async (path) -> FS.unlink path

      context.test "rm"

## rmDir / rmdir

Removes a directory.

      rmDir = rmdir = (path) -> FS.rmdir path

      context.test "rmdir", ->
        # test is effectively done with mkdirp test

## isDirectory

      isDirectory = async (path) -> (yield stat path).isDirectory()

      context.test "isDirectory", ->
        assert (yield isDirectory "./test")

## isFile

      isFile = async (path) -> (yield stat path).isFile()

      context.test "isFile", ->
        assert (yield isFile "./test/lines.txt")

## mkDir / mkdir

Creates a directory. Takes a `mode` and a `path`. Assumes any intermediate directories in the path already exist.

      {curry, binary} = require "./core"
      mkDir = mkdir = curry binary (mode, path) -> FS.mkdir path, mode

      context.test "mdkir", ->
        yield mkdir '0777', "./test/foobar"
        assert (yield isDirectory "./test/foobar")
        yield rmdir "./test/foobar"

## mkDirP / mkdirp

Creates a directory and any intermediate directories in the given `path`. Takes a `mode` and a `path`.

      {dirname} = require "path"
      {curry, binary} = require "./core"
      mkDirP = mkdirp =  curry binary async (mode, path) ->
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

      module.exports = {read, write, rm, stat, exist, exists,
        isFile, isDirectory, readdir, readDir, ls, lsR, lsr,
        mkdir, mkDir, mkdirp, mkDirP, chdir, chDir, rmdir, rmDir}
