    log = -> console.log arguments...
    {async, call, benchmark, times} = require "../../src/index"

    s = -> true
    a = async -> yield true

    N = 1e6
    log "synchronous:", benchmark -> times s, N
    log "asynchronous:", benchmark -> times a, N
