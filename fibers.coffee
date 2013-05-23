# Fibers

# Candidate for promotion.

# requireFibers = (method) ->
#   try
#     require "fiber"
#   catch e
#     throw $.error["requires-node-fibers"] method



$.Catalog.add 
  "requires-node-fibers": (method) -> "Fairmont.#{method} requires node-fibers"
  "no-active-fiber": (method) -> "Fairmont.#{method} requires a currently running Fiber"
    

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
