# File System Functions

    {liftAll} = require "when/node"
    FS = (liftAll require "fs")
    {Method} = require "./multimethods"
    {async} = require "./async"

## stat

Synchronously get the stat object for a file.

    stat = (path) -> FS.stat path

## exists

Check to see if a file exists.

    exists = exist = async (path) ->
      try
        yield FS.stat path
        true
      catch
        false

## read

Read a file and return a UTF-8 string of the contents.

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

## readDir / readdir

Get the contents of a directory as an array.

    readdir = readDir = (path) -> FS.readdir path

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

## glob

Glob a directory.

    {Minimatch} = require "minimatch"
    glob = async (pattern, path) ->
      minimatch = new Minimatch pattern
      match = (path) ->
        minimatch.match path
      _path for _path in (yield lsR path) when match _path

## write

Synchronously write a UTF-8 string or data buffer to a file.

    write = (path, content) -> FS.writeFile path, content

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

## rm

Removes a file.

    rm = async (path) -> FS.unlink path

## rmDir / rmdir

Removes a directory.

    rmDir = rmdir = (path) -> FS.rmdir path

## isDirectory

    isDirectory = async (path) -> (yield stat path).isDirectory()

## isFile

    isFile = async (path) -> (yield stat path).isFile()

## mkDir / mkdir

Creates a directory. Takes a `mode` and a `path`. Assumes any intermediate directories in the path already exist.

    {curry, binary} = require "./core"
    mkDir = mkdir = curry binary (mode, path) -> FS.mkdir path, mode

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


---

    module.exports = {read, write, rm, stat, exist, exists,
      isFile, isDirectory, readdir, readDir, ls, lsR, lsr, glob,
      mkdir, mkDir, mkdirp, mkDirP, chdir, chDir, rmdir, rmDir}
