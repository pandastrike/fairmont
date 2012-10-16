$ = {}

$.Catalog = 
  messages: {}
  errors: {}
  add: (messages) ->
    for key,fn of messages
      $.Catalog.messages[key] = fn
      $.Catalog.errors[key] = (args...) ->
        new Error fn args...
    $.Catalog

$.message = (key) -> $.Catalog.messages[key]

$.error = (string) -> $.Catalog.errors[string] or new Error string

$.read = (path) -> FileSystem.readFileSync(path,'utf-8')

$.readdir = (path) -> FileSystem.readdirSync(path)

$.stat = (path) -> FileSystem.statSync(path)

$.Catalog.add 
  "requires-node-fibers": (method) -> "Fairmont.#{method} requires node-fibers"
  "no-active-fiber": (method) -> "Fairmont.#{method} requires a currently running Fiber"
    
# Crypto-related

Crypto = require "crypto"

$.md5 = (string) -> Crypto.createHash('md5').update(string,'utf-8').digest("hex")

$.base64 = (string) -> new Buffer(string).toString('base64')

# Attributes  

$.Attributes = 

  reader: (name, fn=null) ->

    fn ?= -> @["_#{name}"]

    Object.defineProperty @::, name,
      configurable: true
      enumerable: true
      get: fn

    @

  writer: (name, fn=null) ->

    fn ?= (value) -> 
      @["_#{name}"] = value
      value

    Object.defineProperty @::, name,
      configurable: true
      enumerable: true
      set: fn

    @

$.include = (object, mixins...) ->

  for mixin in mixins
    for key, value of mixin
      object[key] = value
  object

$.merge = (objects...) ->
  
  destination = {}
  for object in objects
    destination[k] = v for k, v of object
  destination

$.abort = -> process.exit -1

# Fibers

requireFibers = (method) ->
  try
    require "fiber"
  catch e
    throw $.error["requires-node-fibers"] method
  
assertFiber = (method) ->
  Fiber = requireFibers method
  (throw $.error["no-active-fiber"] method) unless Fiber.current?
  Fiber

$.sync = (fn) ->
  Fiber = assertFiber("sync")
  Future = require "fibers/future"
  fn = Future.wrap fn
  -> fn(arguments...).wait()

$.fiber = (fn) ->
  Fiber = requireFibers("fiber")
  (args...) -> Fiber( -> fn(args...) ).run()

$.sleep = (ms) ->
  Fiber = assertFiber()
  fiber = Fiber.current
  setTimeout (-> fiber.run()), ms
  Fiber.yield()

# Callback Management

$.streamline = (callback) ->
  (fn) ->
    (error,result) ->
      if error
        callback(error)
      else
        fn(result)

$.optimistic = (callback) ->
  (result) ->
    callback null, result
  
$.callbacks = {}

$.callbacks.logError = $.streamline (error) ->
  $.log error if error?

$.callbacks.fatalError = $.streamline (error) ->
  if error?
    $.log error
    $.abort
    
$.log = (thing) ->
  
  if thing instanceof Error
    {name,message} = thing
    process.stderr.write "#{name}: #{message}\n"
  else
    console.log "#{thing}"

$.fatalError = (error) ->
  $.log error
  $.abort()

$.w = (string) -> string.trim().split /\s+/

module.exports = $