assert = require "assert"
Amen = require "amen"

Amen.describe "Iterator functions", (context) ->

  {isIterable, isAsyncIterable,
    iterator, isIterator, isAsyncIterator,
    isIteratorFunction, isAsyncIteratorFunction,
    iteratorFunction, repeat,
    collect, map, each, fold, reduce, foldr, reduceRight,
    select, reject, filter, any, all,
    zip, unzip, assoc, project, flatten, compact, partition,
    sum, average, join, delimit,
    where,
    take, takeN,
    events, stream, lines, split} = require "../src/iterator"

  context.test "isIterable", -> assert isIterable [1, 2, 3]

  context.test "iteratorFunction", ->
    assert isIteratorFunction iteratorFunction [1..5]

  context.test "collect", ->
    {first} = require "../src/array"
    assert (first collect [1..5]) == 1

  context.test "map", ->
    i = map Math.sqrt, [1, 4, 9]
    assert i().value == 1
    assert i().value == 2
    assert i().value == 3
    assert i().done

  context.test "each", ->
    {last} = require "../src/array"
    assert (last each ((x) -> x + 1), [1..5]) == 6

  context.test "fold/reduce", ->
    {add} = require "../src/numeric"
    sum = fold 0, add
    assert (sum [1..5]) == 15

  context.test "foldr/reduceRight", ->
    {add} = require "../src/numeric"
    {push} = require "../src/array"
    assert (foldr "", add, "panama") == "amanap"

  context.test "select", ->
    {odd} = require "../src/numeric"
    i = select odd, [1..9]
    assert i().value == 1
    assert i().value == 3

  context.test "reject", ->
    {odd} = require "../src/numeric"
    i = reject odd, [1..9]
    assert i().value == 2
    assert i().value == 4

  context.test "any", ->
    {odd} = require "../src/numeric"
    assert (any odd, [1..9])
    assert !(any odd, [2, 4, 6])

  context.test "all", ->
    {odd} = require "../src/numeric"
    assert !(all odd, [1..9])
    assert (all odd, [1, 3, 5])

  context.test "zip", ->
    pair = (x, y) -> [x, y]
    i = zip pair, [1, 2, 3], [4, 5, 6]
    assert i().value[0] == 1
    assert i().value[1] == 5
    assert i().value[0] == 3
    assert i().done

  context.test "unzip", ->
    pair = (x, y) -> [x, y]
    unpair = ([ax, bx], [a, b]) ->
      ax.push a
      bx.push b
      [ax, bx]

    assert (unzip unpair, zip pair, "panama", "canary")[0][0] == "p"

  context.test "assoc", ->
    assert (assoc [["foo", 1], ["bar", 2]]).foo == 1

  context.test "project", ->
    {w} = require "../src/string"
    i = project "length", w "one two three"
    assert i().value == 3

  context.test "flatten", ->
    assert (flatten [1, [2, 3], 4, [5, [6, 7]]])[1] == 2

  context.test "compact", ->
    i = compact [1, null, null, 2]
    assert i().value == 1
    assert i().value == 2

  context.test "partition", ->
    i = partition 2, [0..9]
    assert i().value[0] == 0
    assert i().value[0] == 2

  context.test "sum", ->
    assert (sum [1..5]) == 15

  context.test "average", ->
    assert (average [1..5]) == 3
    assert (average [-5..-1]) == -3

  context.test "take", ->

    context.test "takeN", ->
      i = takeN 3, [0..9]
      assert i().value == 0
      assert i().value == 1
      assert i().value == 2
      assert i().done

  context.test "join", ->
    {w} = require "../src/string"
    assert (join w "one two three") == "onetwothree"

  context.test "delimit", ->
    {w} = require "../src/string"
    assert (delimit ", ", w "one two three") == "one, two, three"

  context.test "where", ->
    pair = (x, y) -> [x, y]
    assert (collect where ["a", 1],
      (zip pair, (repeat "a"), [1,2,3,1,2,3])).length == 2

  context.test "events", ->
    {createReadStream} = require "fs"
    i = events "data", createReadStream "test/data/lines.txt"
    assert (yield i()).value.toString() == "one\ntwo\nthree\n"
    assert (yield i()).done

  context.test "stream", ->
    {createReadStream} = require "fs"
    i = stream createReadStream "test/data/lines.txt"
    assert ((yield i()).value.toString() == "one\ntwo\nthree\n")
    assert (yield i()).done

  context.test "split", ->
    i = split ((x) -> x.split("\n")), ["one\ntwo\n", "three\nfour"]
    assert i().value == "one"
    assert i().value == "two"
    assert i().value == "three"
    assert i().value == "four"
    assert i().done

  context.test "lines", ->
    {createReadStream} = require "fs"
    i = lines stream createReadStream "test/data/lines.txt"
    assert ((yield i()).value) == "one"
    assert ((yield i()).value) == "two"
    assert ((yield i()).value) == "three"
    assert ((yield i()).done)
