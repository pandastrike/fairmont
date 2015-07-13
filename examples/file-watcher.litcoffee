    {join} = require "path"
    fs = require "fs"
    {each, start, flow, events, throttle,
      map, async, shell, lsR} = require "../src/index"

    src = join __dirname, "..", "src"

    watch = each (path) ->
      start flow [
        events "change", fs.watch path
        throttle 3000
        map ([event, file]) ->
          console.log "Detected change in #{file}"
          shell "npm test"
        map async (s) -> console.log (yield s).stdout
      ]

    watch lsR src
