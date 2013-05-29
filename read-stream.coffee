# This was an experiment that failed because of some weirdness with streams.
# If you take process.stdin that has been redirected it works okay. If you
# take process.stdin that has been piped, it fails with an "Offset is out of
# bounds" error. More generally, if you don't make sure the stream is in the
# right state before calling, you'll get an error. So, in practice, it's not
# really useful. It ends up being easier to call read("/dev/stdin").

$.readStream = (stream) ->
  return unless stream.fd?
  {readSync} = require "fs"
  {fd,bufferSize} = stream
  bufferSize ?= 65536
  result = ""
  buffer = new Buffer( bufferSize )
  try
    while ( length = readSync( fd, buffer, 0, bufferSize ) ) > 0
      result += buffer.toString( "utf-8", 0 , length )
  catch e
    # treat errors like an empty stream
    console.log e
  result
