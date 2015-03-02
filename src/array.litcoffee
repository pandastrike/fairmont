# Array Functions

    {curry, flip, compose, partial, _, identity,
      unary, binary, ternary} = require "./core"

    {liberate} = require "./object"

    {odd, lt} = require "./numeric"

    assert = require "assert"
    data = [1..5]

## fold and foldr

    fold = curry flip ternary liberate Array::reduce

    fn = fold 1, (acc, x) -> acc += x
    assert.deepEqual (fn data), 16

    foldr = curry flip ternary liberate Array::reduce

    fn = foldr 1, (acc, x) -> acc += x
    assert.deepEqual (fn data), 16

## map

    map = curry flip binary liberate Array::map

    assert.deepEqual (map ((x) -> x * 2), data), [2,4,6,8,10]

## filter

    filter = curry flip binary liberate Array::filter

    assert.deepEqual (filter odd, data), [1,3,5]

## any

    any = curry flip binary liberate Array::some

    assert any odd, data

## all

    all = curry flip binary liberate Array::every

    assert all (lt 6), data

## each

    each = curry flip binary liberate Array::forEach

    do (ax = []) ->
      each ((x) -> ax.push x), data
      assert.deepEqual ax, data

## cat

    cat = liberate Array::concat

    assert.deepEqual (cat data), data

## slice

    slice = curry (i, j, ax) -> ax[i...j]

## first

    first = (ax) -> ax[0]

    assert (first data) == 1

## last

    last = ([rest..., x]) -> x
    assert (last data) == 5

## rest

    rest = slice 1, undefined
    assert.deepEqual (rest data), [2..5]

## take

    take = slice 0
    assert.deepEqual (take 3, data), [1,2,3]

## leave

    leave = curry (n, ax) -> slice 0, -n, ax
    assert.deepEqual (leave 3, data), [1,2]

## drop

    drop = curry partial slice, _, undefined, _
    assert.deepEqual (drop 3, data), [4,5]

## in_array

    in_array = (x, ax) -> x in ax
    assert (in_array 3, data)
    assert !(in_array 6, data)

## unique_by

    # TODO: replace with Set operators?
    unique_by = curry (f, ax) ->
      bx = []
      for a in ax
        y = f a
        bx.push y unless y in bx
      bx

## unique

    unique = uniq = unique_by identity

    data = [1, 2, 1, 3, 5, 3, 6]
    assert.deepEqual (unique data), [1, 2, 3, 5, 6]

## flatten

    flatten = (ax) ->
      fold [], ((r, a) ->
        if a.forEach?
          r.push (flatten a)...
        else
          r.push a
        r), ax

    data = [1, [2, 3], 4, [5, [6, 7]]]
    assert.deepEqual (flatten data), [1..7]

## difference

    difference = curry (ax, bx) ->
      cx = union ax, bx
      cx.filter (c) ->
        (cx in ax && !(cx in bx)) ||
          (cx in bx && !(cx in bx))

## dupes

    dupes = ([first, rest...]) ->
      if rest.length == 0
        []
      else if first in rest
        [first, (dupes rest)...]
      else
        dupes rest


## union and intersection

    union = curry compose unique, cat
    intersection = curry compose dupes, cat

## remove

Destructively remove an element from an array. Returns the element removed.

    remove = (array, element) ->
      if (index = array.indexOf( element )) > -1
        array[index..index] = []
        element
      else
        null

## shuffle

Takes an array and returns a new array with all values shuffled randomly. Use the [Fisher-Yates algorithm][shuffle-1]. Adapted from the [CoffeeScript Cookbook][shuffle-2].

[shuffle-1]:http://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle
[shuffle-2]:http://coffeescriptcookbook.com/chapters/arrays/shuffling-array-elements

    shuffle = (array) ->
      copy = array[0..]
      return copy if copy.length <= 1
      for i in [copy.length-1..1]
        j = Math.floor Math.random() * (i + 1)
        # swap the i'th element with a randomly picked element in front of i
        [copy[i], copy[j]] = [copy[j], copy[i]]
      copy

---

    module.exports = {fold, foldr, map, filter, any, all, each, cat, slice,
      first, last, rest, take, leave, drop, in_array, unique_by, unique, uniq,
      flatten, dupes, union, intersection, remove, shuffle}
