# Iterator Functions

Iterator functions can operate on iteratables, iterators, or iterator functions. Many builtin JavaScript types are iterable, such as Arrays, Strings, Maps, and so on. Thus, functions that take iterators will work on any of these types.

Using iterator functions is often more efficient than operating directly on objects, since values are only obtained when the iterator function is called.

Some functions _collect_ an iterator into another value. For example, `assoc` takes an iterator that returns pairs and creates an object whose properties are the first element of the pair and whose values are the second element.

Any iterable can be turned into an array via `collect`. Thus, any array function can be applied to an iterable. In some cases, a function is an iterator function when, in fact, it must first collect the iterator. That is, when it is effectively an Array function. These are included here when they complement another iterator function that operate directly on an iterable (and thus take advantage of lazy evaluation.)

For example, `any` collects an iterator into a true or false value. It does not necessarily need to traverse an entire iterable to do so. However, `all`, by definition, must traverse the entire iterable to return a value. Arguably, it consequently belongs with the Array functions. We include it here since it complements `any`.

    {assert, describe} = require "./helpers"

    {curry} = require "./core"

    promise = require "when"
    {call, async} = do ->
      {lift, call} = require "when/generator"
      {async: lift, call}

    describe "Iterator functions", (context) ->


## is_iterable

      is_iterable = (x) -> x[Symbol.iterator]?

      context.test "is_iterable", ->
        assert is_iterable [1, 2, 3]

## is_iterator

      is_iterator = (x) -> x?.next?

## iterator

      {is_function} = require "./type"
      {wrap} = require "./core"

      iterator = (x) ->
        if is_iterable x
          x[Symbol.iterator]()
        else if is_iterator x
          x
        # TODO: fix these
        else if (is_function x) && (x.length == 0)
          next: x
        else
          next: wrap x

      context.test "is_iterator", ->
        assert is_iterator (iterator [1, 2, 3])

      context.test "iterator", ->
        assert is_function (iterator [1, 2, 3]).next

## iterate

      iterate = (x) ->
        i = iterator x
        f = async ->
          {done, value} = i.next()
          {done, value: yield promise value}
        f[Symbol.iterator] = wrap i
        f

      context.test "iterate", ->
        i = iterate [1, 2, 3]
        assert is_iterable i
        assert (yield i()).value == 1
        assert (yield i()).value == 2
        assert (yield i()).value == 3
        assert (yield i()).done

## repeat

Analogous to `wrap` (the K combinator) for an iterator. Always produces the same value `x`.

      repeat = (x) ->
        -> done: false, value: x

## collect

      collect = async (i) ->
        i = iterate i
        done = false
        result = []
        until done
          {done, value} = yield i()
          result.push value unless done
        result

      context.test "collect", ->

        {first} = require "./array"
        assert (first yield collect [1..5]) == 1

## each

      each = async (f, i) ->
        i = iterate i
        done = false
        until done
          {done, value} = yield i()
          f value unless done
        undefined

## map

      map = curry (f, i) ->
        i = iterate i
        async ->
          {done, value} = yield i()
          unless done then {done, value: yield promise f value} else {done}

      context.test "map", ->
        double = (x) -> x * 2
        x = collect map double, [1,2,3]
        assert x[1] == 4

## fold

      {ternary} = require "./core"

      fold = curry ternary async (x, f, i) ->
        i = iterate i
        done = false
        until done
          {done, value} = yield promise i()
          x = (f x, value) unless done
        x

      {add} = require "./numeric"
      context.test "fold", ->
        assert (yield fold 0, add, [1..5]) == 15

## foldr

      {flip} = require "./core"
      {detach} = require "./object"

      _foldr = flip ternary detach Array::reduceRight

      foldr = curry ternary async (x, f, i) ->
        _foldr x, f, (yield collect iterate i)

      context.test "foldr", ->
        assert (yield foldr "", add, "panama") == "amanap"

## select

      select = curry (f, i) ->
        i = iterate i
        done = false
        async ->
          unless done
            found = false
            until done || found
              {value, done} = yield promise i()
              found = f value unless done
            if found then {done, value} else {done}
          else
            {done}

      context.test "select", ->
        {second} = require "./array"
        {odd} = require "./numeric"
        assert (second yield collect select odd, [0..9]) == 3

## reject

      {negate} = require "./logical"
      reject = curry (f, i) -> select (negate f), i

      context.test "reject", ->
        {second} = require "./array"
        {odd} = require "./numeric"
        assert (second yield collect reject odd, [0..9]) == 2

## any

      {binary} = require "./core"
      any = curry binary async (f, i) ->
        i = iterate i
        done = false
        found = false
        until done || found
          {done, value} = yield promise i()
          found = (f value) unless done
        found

      context.test "any", ->
        {odd} = require "./numeric"
        count = 0
        test = (x) -> count++; odd x
        assert (yield any test, [0..9])
        assert count == 2

## all

      all = curry binary async (f, i) ->
        !yield any (negate f), i

      context.test "all", ->
        {odd} = require "./numeric"
        assert !(yield all odd, [0..9])
        assert (yield all (-> true), "foobar")


## zip

      zip = (i, j) ->
        i = iterate i
        j = iterate j
        async ->
          if (_i = yield i()).done || (_j = j()).done
            done: true
          else
            done: false, value: [_i.value, _j.value]

      context.test "zip", ->
        {second, third} = require "./array"
        assert (second third yield collect zip [1, 2, 3], [4, 5, 6]) == 6

## unzip

      _unzip = ([ax, bx], [a, b]) ->
        ax.push a
        bx.push b
        [ax, bx]

      unzip = (i) -> fold [[],[]], _unzip, i

      context.test "unzip", ->
        {first} = require "./array"
        {to_string} = require "./string"
        assert (fold "", add, first collect unzip zip "panama", "canary") ==
          "panama"

## assoc

      {first, second} = require "./index"
      assoc = async (i) ->
        do (i = iterate i) ->
          result = {}
          until done
            {done, value} = yield i()
            result[first value] = (second value) if value?
          result

      context.test "assoc", ->
        assert (yield assoc [["foo", 1], ["bar", 2]]).foo == 1


## project

      {property} = require "./object"
      {w} = require "./string"
      project = curry binary async (p, i) -> yield map (property p), i

      {third} = require "./array"
      context.test "project", ->
        assert (third collect project "length", w "one two three") == 5


## flatten

      flatten = (ax) ->
        fold [], ((r, a) ->
          if a.forEach?
            r.push (flatten a)...
          else
            r.push a
          r), ax

      context.test "flatten", ->
        do (data = [1, [2, 3], 4, [5, [6, 7]]]) ->
          assert (second yield flatten data) == 2


## compact

      {is_value} = require "./type"
      compact = select is_value

      context.test "compact", ->
        assert (second collect compact [1, null, null, 2]) == 2


## partition

      partition = curry (n, i) ->
        i = iterate i
        done = false
        async ->
          batch = []
          until done || batch.length == n
            {done, value} = yield promise i()
            batch.push value unless done
          if done then {done} else {value: batch, done}

      context.test "partition", ->
        {first, second} = require "./array"
        assert (first second collect partition 2, [0..9]) == 2

## take

      take = curry (n, i) ->
        i = iterate i
        done = false
        async ->
          unless done || n-- == 0
            {done, value} = yield promise i()
            if done then {done} else {done, value}
          else
            done = true
            {done}

      {last} = require "./array"
      context.test "take", ->
        assert (last collect take 3, [1..5]) == 3

## leave

      leave = curry binary async (n, i) ->
        (yield collect i)[0...-n]

      context.test "leave", ->
        assert (last leave 3, [1..5]) == 2

## skip

      skip = curry binary async (n, i) ->
        (yield collect i)[n..-1]

      context.test "skip", ->
        assert (first skip 3, [1..5]) == 4

## sample

Sample 1% of the integers up to 1 million. Take the first 500.

```coffee
collect take 500, sample 0.01, [0..1e6]
```

      sample = curry (n, i) ->
        _sample = -> Math.random() < n
        select _sample, i

      context.test "sample"

## sum

Sum the numbers produced by a given iterator.

This is here instead of in [Numeric Functions](./numeric.litcoffee) to avoid forward declaring `fold`.

      {add} = require "./numeric"
      sum = fold 0, add

      context.test "sum", ->
        assert (sum [1..5]) == 15

## average

Average the numbers producced by a given iterator.

This is here instead of in [Numeric Functions](./numeric.litcoffee) to avoid forward declaring `fold`.

      average = (i) ->
        j = 0
        f = (r, n) -> r += ((n - r)/++j)
        fold 0, f, i

      context.test "average", ->
        assert (average [1..5]) == 3
        assert (average [-5..-1]) == -3

## join

Concatenate the strings produced by a given iterator. Unlike `Array::join`, this function does not delimit the strings. See also: `delimit`.

This is here instead of in [String Functions](./string.litcoffee) to avoid forward declaring `fold`.

      {cat} = require "./array"
      join = fold "", add

      context.test "join", ->
        {w} = require "./string"
        assert (join w "one two three") == "onetwothree"

## delimit

Like `join`, except that it takes a delimeter, separating each string with the delimiter. Similar to `Array::join`, except there's no default delimiter. The function is curried, though, so calling `delimit ' '` is analogous to `Array::join` with no delimiter argument.

      delimit = curry (d, i) ->
        f = (r, s) -> if r == "" then r += s else r += d + s
        fold "", f, i

      context.test "delimit", ->
        {w} = require "./string"
        assert (delimit ", ", w "one two three") == "one, two, three"

## where

Performs a `select` using a given object object. See `query`.

      {query} = require "./object"
      {cat} = require "./array"
      where = curry (example, i) ->
        select (query example), i

      context.test "where", ->
        assert (collect where ["a", 1],
          (zip (repeat "a"), [1,2,3,1,2,3])).length == 2

---

      module.exports = {is_iterable, iterator, is_iterator, iterate,
        collect, map, fold, foldr, select, reject, any, all, zip, unzip,
        assoc, project, flatten, partition, take, leave, skip, sample,
        sum, average, join, delimit, where, repeat}
