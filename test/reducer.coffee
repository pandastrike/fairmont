assert = require "assert"
Amen = require "amen"

Amen.describe "Reducer functions", (context) ->

  {collect, each, fold, reduce, foldr, reduceRight,
    any, all, zip, unzip, assoc, flatten,
    sum, average, join, delimit} = require "../src/reducer"

  context.test "collect", ->
    {first} = require "../src/array"
    assert (first collect [1..5]) == 1

  context.test "each", ->
    {identity} = require "../src/core"
    assert !(each ((x) -> x + 1), [1..5])?

  context.test "fold/reduce", ->
    {add} = require "../src/numeric"
    sum = fold 0, add
    assert (sum [1..5]) == 15

  context.test "foldr/reduceRight", ->
    {add} = require "../src/numeric"
    {push} = require "../src/array"
    assert (foldr "", add, "panama") == "amanap"

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

  context.test "flatten", ->
    assert (flatten [1, [2, 3], 4, [5, [6, 7]]])[1] == 2

  context.test "sum", ->
    assert (sum [1..5]) == 15

  context.test "average", ->
    assert (average [1..5]) == 3
    assert (average [-5..-1]) == -3

  context.test "join", ->
    {w} = require "../src/string"
    assert (join w "one two three") == "onetwothree"

  context.test "delimit", ->
    {w} = require "../src/string"
    assert (delimit ", ", w "one two three") == "one, two, three"
