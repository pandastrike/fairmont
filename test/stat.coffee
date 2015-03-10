{call} = require "when/generator"
async = (require "when/generator").lift
{readdir, stat} = require "../src/index"

call ->
  get_dirs = async ->
    file for file in (yield readdir ".") when (yield stat file).isDirectory()

  console.log yield get_dirs()
