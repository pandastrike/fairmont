# Candidate for promotion into it's own npm.

$ = module.exports

class Signature 
  
  constructor: -> 
    @signatures = {}
    @failHandler = => false
  
  on: (types,processor) ->
    @signatures[types.join "."] = processor
    @
  
  fail: (handler) =>
    @failHandler = handler
    @

  match: (args) -> 
    types = ($.type arg for arg in args)
    signature = types.join "."
    processor = @signatures[signature]
    if processor?
      processor
    else
      console.log signature
      console.log @signatures
      @failHandler
    
$.overload = (declarations) ->
  signature = (declarations new Signature)
  (args...) ->
    ((signature.match args) args...)

$.Overloading = 
  overload: (name,declarations) ->
    @::[name] = $.overload declarations
    @
