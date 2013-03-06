{delegate,overload} = require "./index"
{EventEmitter} = require "events"

# class Foo
#   
#   constructor: ->
#     @events = new EventEmitter
#     delegate @, @events
#     
# foo = new Foo
# foo.on "bar", -> console.log "Yep"
# foo.emit "bar"


class Foo
  
  baz: (x) ->
    x * x
    
class Bar extends Foo
  
  baz: (args...) ->

    @baz = overload (signature) =>

      signature.on ["number"], (x) =>
        super x

      signature.on ["number", "number"], (x,y) =>
        x * y

      signature.on ["string"], (s) =>
        super parseInt s

      signature.fail =>
        "Terribly sorry!"

    @baz args...
        
bar = new Bar

console.log bar.baz 5
console.log bar.baz "6"
console.log bar.baz 7, 8
console.log bar.baz bad: 9

# dan$ coffee test.coffee 
# 25
# 36
# 56
# Terribly sorry!
