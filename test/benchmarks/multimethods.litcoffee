    log = -> console.log arguments...
    {call, Method, benchmark, times} = require "../../src/index"

    a = Method.create()

    p1 = -> true
    p2 = -> false
    Method.define a, p1, -> true
    Method.define a, p2, -> true

    b = -> true

    N = 1e6

    log "multimethod:", (benchmark -> times (-> a 0), N)
    log "function:", (benchmark -> times (-> b 0), N)
