{resolve} = require "path"
{read, readdir} = require "./src/fs"

dirname = resolve(__dirname, "src")
for filename in readdir(dirname)
  content = read(resolve(dirname, filename))
  lines = content.match /^#.*$/gm
  if lines?
    for line in lines
      console.log line.replace(/^#\s*/, "")
  console.log "\n\n"
