assert = require "assert"
Amen = require "amen"
FS = require "../src/fs"

Amen.describe "File system functions", (context) ->

  context.test "stat", ->
    {stat} = FS
    assert (yield stat "test/data/lines.txt").size?

  context.test "exists", ->
    {exists} = FS
    assert (yield exists "test/data/lines.txt")
    assert !(yield exists "test/data/does-not-exist")

  do ->

    {read} = FS

    context.test "read", ->
      assert (yield read "test/data/lines.txt") == "one\ntwo\nthree\n"

      context.test "write", ->
        {write} = FS
        write "test/data/lines.txt", (yield read "test/data/lines.txt")

    context.test "read buffer", ->
      assert (yield read "test/data/lines.txt", "binary").constructor == Buffer

    context.test "read stream", ->
      {createReadStream} = require "fs"
      s = createReadStream "test/data/lines.txt"
      assert (yield read s) == "one\ntwo\nthree\n"

  context.test "readdir", ->
    {readdir} = FS
    assert "lines.txt" in (yield readdir "test/data")

  context.test "ls", ->

    context.test "lsR", ->
      {lsR} = FS
      {join} = require "path"
      testDir = join __dirname, ".."
      assert (join testDir, "test/data/lines.txt") in (yield lsR testDir)

  context.test "glob", ->
    {glob} = FS
    {join} = require "path"
    src = join __dirname, "..", "src"
    assert ((join src, "fs.litcoffee") in
      (yield glob "**/*.litcoffee", src))

  context.test "chdir", ->
    {chdir} = FS
    {join} = require "path"
    src = join __dirname, "..", "src"
    cwd = process.cwd()
    chdir src, ->
      fs = require "fs"
      assert (fs.statSync "fs.litcoffee").size?
    assert cwd == process.cwd()

  context.test "rm"

  context.test "rmdir", ->

    context.test "mkdir", ->
      {mkdir, rmdir, isDirectory} = FS
      yield mkdir '0777', "./test/data/foobar"
      assert (yield isDirectory "./test/data/foobar")
      yield rmdir "./test/data/foobar"

    context.test "mkdirp", ->
      {mkdirp, rmdir, isDirectory} = FS
      yield mkdirp '0777', "./test/data/foo/bar"
      assert (yield isDirectory "./test/data/foo/bar")
      yield rmdir "./test/data/foo/bar"
      yield rmdir "./test/data/foo"

  context.test "isDirectory", ->
    {isDirectory} = FS
    assert (yield isDirectory "./test/data")

  context.test "isFile", ->
    {isFile} = FS
    assert (yield isFile "./test/data/lines.txt")
