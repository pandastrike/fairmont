{readStream} = require "./index"
{resolve} = require "path"
{createReadStream} = require "fs"

stream = createReadStream( resolve( __dirname, "test2.coffee" ) )
stream.on "open", -> console.log readStream(stream)
