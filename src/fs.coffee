$ = {}

$.exists = (path) ->
  FileSystem = require "fs"
  FileSystem.existsSync(path)

$.read = (path) ->
  FileSystem = require "fs"
  FileSystem.readFileSync(path, 'utf-8')

$.readdir = (path) ->
  FileSystem = require "fs"
  FileSystem.readdirSync(path)

$.stat = (path) ->
  FileSystem = require "fs"
  FileSystem.statSync(path)

$.write = (path, content) ->
  FileSystem = require "fs"
  FileSystem.writeFileSync path, content

$.chdir = (dir, fn) ->
  cwd = process.cwd()
  process.chdir dir
  rval = fn()
  process.chdir cwd
  rval

$.rm = (path) ->
  FileSystem = require "fs"
  FileSystem.unlinkSync(path)

$.rmdir = (path) ->
  FileSystem = require "fs"
  FileSystem.rmdirSync( path )

module.exports = $
