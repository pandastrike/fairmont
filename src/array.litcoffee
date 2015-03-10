# Array Functions

    {curry, flip, compose, partial, _, identity,
      unary, binary, ternary} = require "./core"

    {detach} = require "./object"
    {deep_equal} = require "./type"

    {odd, lt} = require "./numeric"

    {assert, describe} = require "./helpers"

    describe "Array functions", (context) ->

## cat

      cat = detach Array::concat

      context.test "cat", ->
        data = [1..5]
        assert deep_equal (cat data), data

## slice

      slice = curry (i, j, ax) -> ax[i...j]

## first

      first = (ax) -> ax[0]

      context.test "first", ->
        data = [1..5]
        assert (first data) == 1

      second = (ax) -> ax[1]
      third = (ax) -> ax[2]


## last

      last = ([rest..., x]) -> x

      context.test "last", ->
        do (data = [1..5]) -> assert (last data) == 5

## rest

      rest = slice 1, undefined

      context.test "rest", ->
        do (data = [1..5]) -> assert deep_equal (rest data), [2..5]

## includes

      includes = (x, ax) -> x in ax

      context.test "includes", ->
        do (data = [1..5]) ->
          assert (includes 3, data)
          assert !(includes 6, data)

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

      context.test "unique", ->
        do (data = [1, 2, 1, 3, 5, 3, 6]) ->
          assert deep_equal (unique data), [1, 2, 3, 5, 6]

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

      context.test "dupes", ->
        do (data = [1, 2, 1, 3, 5, 3, 6]) ->
          assert deep_equal (dupes data), [1, 3]

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

      shuffle = (ax) ->
        bx = cat ax
        unless bx.length <= 1
          for b, i in bx
            j = i
            while j == i
              j = Math.floor Math.random() * bx.length
            [bx[i], bx[j]] = [bx[j], bx[i]]
          if deep_equal ax, bx then shuffle ax else bx
        else
          bx

      context.test "shuffle", ->
        do (data = [1..5]) ->
          assert !deep_equal (shuffle data), data

## range

Generates an array of integers based on the given range.

      range = (start, finish) -> [start..finish]

      context.test "range", -> assert deep_equal (range 1, 5), [1..5]

---


      module.exports = {cat, slice, first, second, third, last, rest,
        includes, unique_by, unique, uniq, dupes, union, intersection,
        remove, shuffle}
