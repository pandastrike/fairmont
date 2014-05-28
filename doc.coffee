{resolve} = require "path"
{read, readdir} = require "./src/fs"

console.log "# Fairmont"
console.log "\nA collection of useful CoffeeScript/JavaScript functions."

dirname = resolve(__dirname, "src")
for filename in readdir(dirname)
  content = read(resolve(dirname, filename))
  lines = content.match /^#.*$/gm
  if lines?
    for line in lines
      comment = line.replace(/^# /, "")
      unless comment.match(/^--/)?
        console.log comment
