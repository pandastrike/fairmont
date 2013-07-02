$ = {}

$.w = w = (string) -> string.trim().split /\s+/

$.capitalize = (string) ->
  string[0].toUpperCase() + string[1..]
  
$.titleCase = (string) ->
  string.toLowerCase().replace(/^(\w)|\W(\w)/g, (char) -> char.toUpperCase())

$.camelCase = (string) ->
  string.toLowerCase().replace(/(\W+\w)/g, (string) -> 
    string.trim().toUpperCase())

$.underscored = (string) ->
  $.plainText(string).replace(/\W+/g, "_")
  
$.dashed = (string) ->
  $.plainText(string).replace(/\W+/g, "-")
  
$.plainText = (string) ->
  string
    .replace( /^[A-Z]/g, (c) -> c.toLowerCase() )
    .replace( /[A-Z]/g, (c) -> " #{c.toLowerCase()}" )  
    .replace( /\W+/g, " " )
    
# Adapted from Mustache.js
$.htmlEscape = do ->
  
  map =
    "&": "&amp;"
    "<": "&lt;"
    ">": "&gt;"
    '"': '&quot;'
    "'": '&#39;'
    "/": '&#x2F;'

  entities = Object.keys( map )
  re = new RegExp( "#{entities.join('|')}", "g" )
  (string) -> string.replace( re, (s) -> map[s] )


# type - reliable, consistent type function. Adapted from:
# http://coffeescriptcookbook.com/chapters/classes_and_objects/type-function
# See also, of course: http://javascript.crockford.com/remedial.html

classToType = new Object
for name in w "Boolean Number String Function Array Date RegExp"
  classToType["[object " + name + "]"] = name.toLowerCase()

$.type = (object) ->
  return "undefined" if object is undefined
  return "null" if object is null
  myClass = Object.prototype.toString.call object
  if myClass of classToType
    return classToType[myClass]
  else
    return "object"

$.remove = (array,element) ->
  if (index = array.indexOf( element )) > -1
    array[index..index] = []
    element
  else
    null
      
$.uniq = (array,hash=(object)-> object.toString()) ->
  uniques = {}
  for element in array
    uniques[ hash(element) ] = element
  uniques[key] for key in Object.keys( uniques )

$.to = (to,from) ->
  if from instanceof to then from else new to from

$.exists = (path) ->
  FileSystem = require "fs"
  FileSystem.existsSync(path)

$.read = (path) -> 
  FileSystem = require "fs"
  FileSystem.readFileSync(path,'utf-8')

$.readdir = (path) -> 
  FileSystem = require "fs"
  FileSystem.readdirSync(path)

$.stat = (path) -> 
  FileSystem = require "fs"
  FileSystem.statSync(path)
  
$.write = (path,content) ->
  FileSystem = require "fs"
  FileSystem.writeFileSync path, content

$.chdir = (dir,fn) ->
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
  
  
# Crypto-related

Crypto = require "crypto"

$.md5 = (string) -> Crypto.createHash('md5').update(string,'utf-8').digest("hex")

$.base64 = (string) -> new Buffer(string).toString('base64')

$.include = include = (object, mixins...) ->

  for mixin in mixins
    for key, value of mixin
      object[key] = value
  object

# Convenient way to define properties
# 
#   class Foo
#     
#     include @, Properties
#     
#     property foo: get: -> "foo"
#     

$.Property = 
  
  property: do ->
    defaults = enumerable: true, configurable: true
    (properties) ->
      for key, value of properties
        include value, defaults
        Object.defineProperty @::, key, value
     
$.merge = (objects...) ->
  
  destination = {}
  for object in objects
    destination[k] = v for k, v of object
  destination
  
$.delegate = (from,to) ->
  
  for name, value of to when ($.type value) is "function"
    do (value) ->
      from[name] = (args...) -> value.call to, args...

$.abort = -> process.exit -1

# Very simplistic memoize - only works for one argument
# where toString is a unique value
  
$.memoize = (fn,hash=(object)-> object.toString()) ->
  memo = {}
  (thing) -> memo[ hash( thing ) ] ?= fn(thing)

$.timer = (wait,action) -> 
  id = setTimeout(action,wait)
  -> clearTimeout( id )  

module.exports = $