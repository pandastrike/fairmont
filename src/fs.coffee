$ = {}

#
## File System Functions
#
# All file-system functions are based on Node's `fs` API. This is not `require`d unless the function is actually invoked.

#
# ### exists ###
#
# Check to see if a file exists.
#
# ```coffee-script
# source = read( sourcePath ) if exists( sourcePath )
# ```

$.exists = (path) ->
  FileSystem = require "fs"
  FileSystem.existsSync(path)

#
# ### read ###
#
# Read a file synchronously and return a UTF-8 string of the contents.
#
# ```coffee-script
# source = read( sourcePath ) if exists( sourcePath )
# ```

$.read = (path) ->
  FileSystem = require "fs"
  FileSystem.readFileSync(path, 'utf-8')


#
# ### readdir ###
#
# Synchronously get the contents of a directory as an array.
#
# ```coffee-script
# for file in readdir("documents")
#   console.log read( file ) if stat( file ).isFile()
# ```

$.readdir = (path) ->
  FileSystem = require "fs"
  FileSystem.readdirSync(path)

#
# ### stat ###
#
# Synchronously get the stat object for a file.
#
# ```coffee-script
# for file in readdir("documents")
#   console.log read( file ) if stat( file ).isFile()
# ```

$.stat = (path) ->
  FileSystem = require "fs"
  FileSystem.statSync(path)

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

module.exports = $
