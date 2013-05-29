{readStream} = require "./index"
{resolve} = require "path"
{createReadStream} = require "fs"

# stream = createReadStream( resolve( __dirname, "test2.coffee" ) )
# stream.on "open", -> console.log readStream(stream)

# process.stdin.setEncoding('utf8');
# console.log readStream( process.stdin )

# 
# process.stdin.on "data", (data) ->
#   console.log data

{read} = require "./index"
console.log read("/dev/stdin")


# { domain: null,
#   _events: null,
#   _maxListeners: 10,
#   _handle: 
#    { writeQueueSize: 0,
#      owner: [Circular],
#      onread: [Function: onread] },
#   writable: true,
#   readable: true,
#   _pendingWriteReqs: 0,
#   _flags: 0,
#   _connectQueueSize: 0,
#   destroyed: false,
#   errorEmitted: false,
#   bytesRead: 0,
#   _bytesDispatched: 0,
#   allowHalfOpen: undefined,
#   fd: 0,
#   _paused: true,
#   pipe: [Function] }


# { domain: null,
#   _events: null,
#   _maxListeners: 10,
#   path: null,
#   fd: 0,
#   readable: true,
#   paused: true,
#   flags: 'r',
#   mode: 438,
#   bufferSize: 65536,
#   pipe: [Function] }
