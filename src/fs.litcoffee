# File System Functions

All file-system functions are based on Node's `fs` API. This is not `require`d unless the function is actually invoked.

    fs = (f) ->
      {liftAll} = require "when/node"
      {call} = (require "when/generator")
      f (liftAll require "fs"), call

## exists

Check to see if a file exists.

    exists = (path) -> fs (FS) -> FS.exists path

## read

Read a file and return a UTF-8 string of the contents.

    read = (path) ->
      fs (FS, call) ->
        call -> (yield FS.readFile path).toString()


## readdir

Synchronously get the contents of a directory as an array.

    readdir = (path) -> fs (FS) -> FS.readdir path



## stat

Synchronously get the stat object for a file.

    stat = (path) -> fs (FS) -> FS.stat path

#
# ### write ###
#
# Synchronously write a UTF-8 string to a file.
#
# ```coffee-script
# write( file.replace( /foo/g, 'bar' ) )
# ```

$.write = (path, content) ->
  FileSystem = require "fs"
  FileSystem.writeFileSync path, content

#
# ### chdir ###
#
# Change directories, execute a function, and then restore the original working directory.
#
# ```coffee-script
# chdir "documents", ->
#   console.log read( "README" )
# ```

$.chdir = (dir, fn) ->
  cwd = process.cwd()
  process.chdir dir
  rval = fn()
  process.chdir cwd
  rval

#
# ### rm ###
#
# Removes a file.
#
# ```coffee-script
# rm "documents/reamde.txt"
# ```

$.rm = (path) ->
  FileSystem = require "fs"
  FileSystem.unlinkSync(path)

#
# ### rmdir ###
#
# Removes a directory.
#
# ```coffee-script
# rmdir "documents"
# ```

$.rmdir = (path) ->
  FileSystem = require "fs"
  FileSystem.rmdirSync( path )

---

    module.exports = {exists, read, readdir, stat}
