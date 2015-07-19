# Array Functions

    {curry, flip, compose, partial, _, identity,
      unary, binary, ternary} = require "./core"

    {detach} = require "./object"

    # array only version of empty, not exported
    empty = (x) -> x.length == 0

## push

    push = curry (ax, a) -> ax.push a ; ax

## cat

Concatenates (joins) arrays.

    cat = detach Array::concat

## slice

Curryied version of `Array::slice`.

    slice = curry (i, j, ax) -> ax[i...j]

## first, second, third, …, nth

Returns the first, second…nth element of an array.

    nth = curry (i, ax) -> ax[i - 1]
    first = nth 1
    second = nth 2
    third = nth 3
    fourth = nth 4
    fifth = nth 5

## last

Returns the last element of an array.

    last = ([rest..., x]) -> x

## rest

Returns all array elements but the first.

    rest = slice 1, undefined

## includes

Check if an element is a member of an array.

    includes = curry (x, ax) -> x in ax

## uniqueBy

Returns a new array containing only unique members of an array,
after transforming them with `f`. This is a generalized version of
[`unique`](#unique) below.

    uniqueBy = curry (f, ax) ->
      bx = []
      for a in ax
        b = f a
        (bx.push b) unless b in bx
      bx

## unique

Returns a new array containing only unique member of an array.

    unique = uniq = uniqueBy identity

## dupes

Returns only the elements that exist more than once.

    dupes = ([a, ax...]) ->
      if empty ax
        []
      else
        bx = dupes ax
        if a in ax && !(a in bx) then [a, bx...] else bx


## union

Set union (combination of two array with duplicates removed).

    union = curry compose unique, cat

## intersection

    intersection = (first, rest...) ->
      if empty rest
        first
      else
        x for x in (intersection rest...) when x in first

## difference

Returns the elements that are not shared between two arrays.

    difference = curry (ax, bx) ->
      cx = union ax, bx
      cx.filter (c) ->
        (c in ax && !(c in bx)) ||
          (c in bx && !(c in ax))

## complement

Returns the complement of the second array relative to the first array.

    complement = curry (ax, bx) -> ax.filter (c) -> !(c in bx)

## remove

Destructively remove an element from an array. Returns the element removed.

    remove = curry (element, ax) ->
      if (index = ax.indexOf( element )) > -1
        ax[index..index] = []
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
        if deepEqual ax, bx then shuffle ax else bx
      else
        bx

## range

Generates an array of integers based on the given range.

    range = curry (start, finish) -> [start..finish]

---

    module.exports = {push, cat, slice, first, second, third, last, rest,
      includes, uniqueBy, unique, uniq, dupes, union, intersection,
      difference, complement, remove, shuffle}
