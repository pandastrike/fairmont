# Test for read_block

I just wanted to make sure I could read from stdin in the same way the bash `read` command does. To run this test, you have to pipe some data via the command line and check the output. It should write the first line from stdin to stdout.

## Example

```sh
ls | coffee --nodejs --harmony ./test/read-block.litcoffee
README.md
```

## Test Code

    {read_block, lines, times} = require "../src/index"
    {call} = require "when/generator"
    call ->
      [rest..., third] = times (read_block lines process.stdin), 3
      console.log yield third
