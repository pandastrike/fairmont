# Iterator Functions

Fairmont introduces the idea of _iterator functions_. Iterator functions are functions that wrap Iterators. Many builtin JavaScript types are iterable, such as Arrays, Strings, Maps, and so on.

Iterator functions are also iterators and iterable. So they can be used anywhere an iterable can be used (ex: in a JavaScript `for` loop). And just as iterators are iterable, so are iterator functions.

Fairmont also supports async iterators, which [are a proposed part of ES7][100]. Async iterators return promises that resolve to iterator value objects. Basically, they work just like normal iterators, except the values take an itermediate form of promises.

[100]:https://github.com/zenparsing/async-iteration/

Iterators allow us to implement lazy evaluation for collection methods. In turn, this allows us to compose some iterator functions without introducing multiple iterations. For example, we can compose `map` with `select` and still only incur a single traversal of the data we're iterating over.

Some functions _collect_ an iterator into another value. In particular, the `collect` function takes an iterator and returns a corresponding array. Once a collection function is introduced, the associated iterator functions will run.

Array functions are included here when they complement another iterator function that operate directly on an iterable. For example, `any` collects an iterator into a true or false value. However, `all`, by definition, must traverse the entire iterable to return a value. Arguably, it consequently belongs with the Array functions. We include it here since it complements `any`.

    {assert, describe} = require "./helpers"

    describe "Iterator functions", (context) ->


## isIterable

      isIterable = (x) -> x?[Symbol.iterator]?

      context.test "isIterable", ->
        assert isIterable [1, 2, 3]

## isAsyncIterable

      isAsyncIterable = (x) -> x?[Symbol.asyncIterator]?

## isIterator

      isIterator = (x) -> x?.next? && isIterable x

## isAsyncIterator

      isAsyncIterator = (x) -> x?.next? && isAsyncIterable x

## iterator

The `iterator` function takes a given value and attempts to return an iterator based upon it. We're using predicates here throughout because they have a higher precedence than `constructor` matches.

      {Method} = require "./multimethods"
      iterator = Method.create()

If we don't have an iterable, we might have a function or a generator function. In that case, we assume we're dealing with an iterator function that simply hasn't been properly tagged.

      {isFunction} = require "./type"
      Method.define iterator, isFunction, (f) ->
        f.next = f
        f[Symbol.iterator] = -> @this
        f

      {isGenerator} = require "./type"
      {async} = require "./generator"
      Method.define iterator, isGenerator, (g) ->
        f = async g
        f.next = f
        f[Symbol.asyncIterator] = -> @this
        f

The simplest case is to just call the iterator method on the value. We can do this when we have something iterable. We have sync and async variants. These are defined last to avoid infinite recursion.

      Method.define iterator, isIterable, (i) -> i[Symbol.iterator]()
      Method.define iterator, isAsyncIterable, (i) -> i[Symbol.asyncIterator]()

## asyncIterator

The `asyncIterator` function is analogous to the `iterator` function—it's job is to ensure that the object given as an argument is a proper asynchronous iterator. The `iterator` function knows to turn a generator into an asynchronous iterator already, but if we have a function producing promises, we need to call this function to declare the type of iterator explicitly.

      asyncIterator = Method.create()

      Method.define asyncIterator, isFunction, (f) ->
        f.next = f
        f[Symbol.asyncIterator] = -> @this
        f

      Method.define iterator, isGenerator, (g) ->
        f = async g
        f.next = f
        f[Symbol.asyncIterator] = -> @this
        f

## iteratorFunction

`iteratorFunction` takes a value and tries to return an `IteratorFunction` based upon it. We're using predicates here throughout because they have a higher precedence than `constructor` matches.

      {Method} = require "./multimethods"
      iteratorFunction = Method.create()

We want to be able to detect whether we have an iterator function. Iterators that are also functions are iterator functions. We have sync and async variants of this test.

      {isFunction} = require "./type"
      isIteratorFunction = (f) -> (isFunction f) && (isIterator f)

      isAsyncIteratorFunction = (f) -> (isFunction f) && (isAsyncIterator f)

If we get an iterable, we want an iterator for it, and then to turn that into an iterator function.

      {either} = require "./logical"
      Method.define iteratorFunction,
        (either isIterable, isAsyncIterable),
        (x) -> iteratorFunction iterator x

If we get an iterator as a value, we simply need to wrap it in a function that calls it's `next` method, and then call `iterator` on that. We define this after the method taking iterables, since iterators are iterables, and we want this function to have precedence.

      Method.define iteratorFunction,
        (either isIterator, isAsyncIterator),
        (i) -> iterator (-> i.next())

If given a function or a Generator function that isn't already an iterator (or an iterator function), we can convert that into an iterator function by simply calling `iterator` on the value, since it's already a function.

      {either} = require "./logical"
      {isFunction, isGenerator} = require "./type"
      Method.define iteratorFunction,
        (either isFunction, isGenerator),
        (f) -> iterator f

Now we can define the trivial case, where we already have an iterator function and just need to return it. This comes last so that it has the highest precedence, since iterator functions are both iterators and functions (and would thus match each of the previous rules and cause an infinite recursion).

      {either} = require "./logical"
      {identity} = require "./core"
      Method.define iteratorFunction,
        (either isIteratorFunction, isAsyncIteratorFunction),
        identity

      context.test "iteratorFunction", ->
        assert isIteratorFunction iteratorFunction [1..5]

## repeat

Analogous to `wrap`for an iterator. Always produces the same value `x`.

      repeat = (x) -> (iterator -> done: false, value: x)

We're going to use `$` internally here to mean a wildcard value for purposes of argument matching.

      $ = (-> true)

## collect

Collect an iterator's values into an array.

      {Method} = require "./multimethods"
      collect = Method.create()

      Method.define collect, $, (x) -> collect (iteratorFunction x)

      Method.define collect, isIteratorFunction,
        (i) ->
          loop
            {done, value} = i()
            break if done
            value

      {async} = require "./generator"
      Method.define collect, isAsyncIteratorFunction,
        async (i) ->
          loop
            {done, value} = yield i()
            break if done
            value

      context.test "collect", ->
        {first} = require "./array"
        assert (first collect [1..5]) == 1

## map

Return a new iterator that will apply the given function to each value produced by the iterator.

      map = Method.create()

      Method.define map, Function, $,
        (f, x) -> map f, (iteratorFunction x)

      {isPromise} = require "./type"
      Method.define map, Function, isPromise, async (f, p) ->
        map f, (yield p)

      Method.define map, Function, isIteratorFunction, (f, i) ->
        iterator ->
          {done, value} = i()
          if done then {done} else {done, value: (f value)}

      Method.define map, Function, isAsyncIteratorFunction, (f, i) ->
        iterator ->
          {done, value} = yield i()
          unless done
            value = f value
            if isPromise value
              value = yield value
          {done, value}

      {curry, binary} = require "./core"
      map = curry binary map

      context.test "map", ->
        i = map Math.sqrt, [1, 4, 9]
        assert i().value == 1
        assert i().value == 2
        assert i().value == 3
        assert i().done

## each

Takes a function and an iterator and applies the given function to each value produced by the iterator, collecting the results into an array.

      {curry, compose, binary} = require "./core"
      each = curry binary compose collect, map

      context.test "each", ->
        {last} = require "./array"
        assert (last each ((x) -> x + 1), [1..5]) == 6

## fold/reduce

Given an initial value, a function, and an iterator, reduce the iterator to a single value, ex: sum a list of integers.

      {curry, ternary} = require "./core"
      fold = Method.create()

      Method.define fold, $, Function, $,
        (x, f, y) -> fold x, f, (iteratorFunction y)

      Method.define fold, $, Function, isIteratorFunction,
        (x, f, i) ->
          loop
            {done, value} = i()
            break if done
            x = f x, value
          x

      Method.define fold, $, Function, isAsyncIteratorFunction,
        async (x, f, i) ->
          loop
            {done, value} = yield i()
            break if done
            x = f x, value
          x

      reduce = fold = curry ternary fold

      {add} = require "./numeric"
      context.test "fold/reduce", ->
        sum = fold 0, add
        assert (sum [1..5]) == 15

## foldr/reduceRight

Given function and an initial value, reduce an iterator to a single value, ex: sum a list of integers, starting from the right, or last, value.

      {curry, ternary} = require "./core"
      foldr = Method.create()


      Method.define foldr, $, Function, $,
        (x, f, y) -> foldr x, f, (iteratorFunction y)

      Method.define foldr, $, Function, isIteratorFunction,
        (x, f, i) -> (collect i).reduceRight(f, x)

      Method.define foldr, $, Function, isAsyncIteratorFunction,
        async (x, f, i) -> (yield collect i).reduceRight(f, x)

      reduceRight = foldr = curry ternary foldr

      {add} = require "./numeric"
      context.test "foldr/reduceRight", ->
        assert (foldr "", add, "panama") == "amanap"

## select/filter

Given a function and an iterator, return an iterator that produces values from the given iterator for which the function returns true.

      select = Method.create()

      Method.define select, Function, $,
        (f, x) -> select f, (iteratorFunction x)

      Method.define select, Function, isIteratorFunction,
        (f, i) ->
          iterator ->
            loop
              {done, value} = i()
              break if done || (f value)
            {done, value}

      Method.define select, Function, isAsyncIteratorFunction,
        (f, i) ->
          iterator ->
            loop
              {done, value} = yield i()
              break if done || (f value)
            {done, value}

      {binary, curry} = require "./core"
      select = filter = curry binary select

      context.test "select", ->
        {odd} = require "./numeric"
        i = select odd, [1..9]
        assert i().value == 1
        assert i().value == 3

## reject

Given a function and an iterator, return an iterator that produces values from the given iterator for which the function returns false.

      {negate} = require "./logical"
      reject = curry (f, i) -> select (negate f), i

      context.test "reject", ->
        {odd} = require "./numeric"
        i = reject odd, [1..9]
        assert i().value == 2
        assert i().value == 4

## any

Given a function and an iterator, return true if the given function returns true for any value produced by the iterator.

      any = Method.create()

      Method.define any, Function, $, (f, x) -> any f, (iteratorFunction x)

      Method.define any, Function, isIteratorFunction,
        (f, i) ->
          loop
            ({done, value} = i())
            break if (done || (f value))
          !done

      Method.define any, Function, isAsyncIteratorFunction,
        async (f, i) ->
          loop
            ({done, value} = yield i())
            break if (done || (f value))
          !done

      {curry, binary} = require "./core"
      any = curry binary any

      context.test "any", ->
        {odd} = require "./numeric"
        assert (any odd, [1..9])
        assert !(any odd, [2, 4, 6])

## all

Given a function and an iterator, return true if the function returns true for all the values produced by the iterator.

      all = Method.create()

      Method.define all, Function, $, (f, x) -> all f, (iteratorFunction x)

      Method.define all, Function, isIteratorFunction,
        (f, i) -> !any (negate f), i

      Method.define all, Function, isAsyncIteratorFunction,
        async (f, i) -> !(yield any (negate f), i)

      all = curry binary all

      context.test "all", ->
        {odd} = require "./numeric"
        assert !(all odd, [1..9])
        assert (all odd, [1, 3, 5])

## zip

Given a function and two iterators, return an iterator that produces values by applying a function to the values produced by the given iterators.

      zip = Method.create()

      Method.define zip, Function, $, $,
        (f, x, y) -> zip f, (iteratorFunction x), (iteratorFunction y)

      Method.define zip, Function, isIteratorFunction, isIteratorFunction,
        (f, i, j) ->
          iterator ->
            x = i()
            y = j()
            if !x.done && !y.done
              value: (f x.value, y.value), done: false
            else
              done: true

      context.test "zip", ->
        pair = (x, y) -> [x, y]
        i = zip pair, [1, 2, 3], [4, 5, 6]
        assert i().value[0] == 1
        assert i().value[1] == 5
        assert i().value[0] == 3
        assert i().done

## unzip

      unzip = (f, i) -> fold [[],[]], f, i

      context.test "unzip", ->
        pair = (x, y) -> [x, y]
        unpair = ([ax, bx], [a, b]) ->
          ax.push a
          bx.push b
          [ax, bx]

        assert (unzip unpair, zip pair, "panama", "canary")[0][0] == "p"

## assoc

Given an iterator that produces associative pairs, return an object whose keys are the first element of the pair and whose values are the second element of the pair.

      {first, second} = require "./array"
      assoc = Method.create()

      Method.define assoc, $, (x) -> assoc (iteratorFunction x)

      Method.define assoc, isIteratorFunction, (i) ->
        result = {}
        loop
          {done, value} = i()
          break if done
          result[(first value)] = (second value)
        result

      Method.define assoc, isAsyncIteratorFunction, (i) ->
        result = {}
        loop
          {done, value} = yield i()
          break if done
          result[(first value)] = (second value)
        result

      context.test "assoc", ->
        assert (assoc [["foo", 1], ["bar", 2]]).foo == 1


## project

      {property} = require "./object"
      {curry} = require "./core"
      project = curry (p, i) -> map (property p), i

      context.test "project", ->
        {w} = require "./string"
        i = project "length", w "one two three"
        assert i().value == 3

## flatten

      _flatten = (ax, a) ->
        if isIterable a
          ax.concat flatten a
        else
          ax.push a
          ax

      flatten = fold [], _flatten

      context.test "flatten", ->
        assert (flatten [1, [2, 3], 4, [5, [6, 7]]])[1] == 2


## compact

      {isDefined} = require "./type"
      compact = select isDefined

      context.test "compact", ->
        i = compact [1, null, null, 2]
        assert i().value == 1
        assert i().value == 2

## partition

      partition = Method.create()

      Method.define partition, Number, $, (n, x) ->
        partition n, (iteratorFunction x)

      Method.define partition, Number, isIteratorFunction, (n, i) ->
        iterator ->
          batch = []
          loop
            {done, value} = i()
            break if done
            batch.push value
            break if batch.length == n
          if done then {done} else {value: batch, done}

      Method.define partition, Number, isAsyncIteratorFunction, (n, i) ->
        iterator ->
          batch = []
          loop
            {done, value} = yield i()
            break if done
            batch.push value
            break if batch.length == n
          if done then {done} else {value: batch, done}

      context.test "partition", ->
        i = partition 2, [0..9]
        assert i().value[0] == 0
        assert i().value[0] == 2

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
        j = 0 # current count
        f = (r, n) -> r += ((n - r)/++j)
        fold 0, f, i

      context.test "average", ->
        assert (average [1..5]) == 3
        assert (average [-5..-1]) == -3

## take

Given a function and an iterator, return an iterator that produces values from the given iterator until the given function returns false when applied to the given iterator's values.

      take = Method.create()

      Method.define take, Function, $,
        (f, x) -> take f, (iteratorFunction x)

      Method.define take, Function, isIteratorFunction,
        (f, i) ->
          iterator ->
            if !done
              {done, value} = i()
              if !done && (f value)
                {value, done: false}
              else
                {done: true}

      take = curry binary take

      context.test "take"

## takeN

Given an iterator, produces the first N values from the given iterator.

      takeN = do ->
        f = (n, i = 0) -> -> i++ < n
        (n, i) -> take (f n), i

      context.test "takeN", ->
        i = takeN 3, [0..9]
        assert i().value == 0
        assert i().value == 1
        assert i().value == 2
        assert i().done

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
      where = curry (example, i) -> select (query example), i

      context.test "where", ->
        pair = (x, y) -> [x, y]
        assert (collect where ["a", 1],
          (zip pair, (repeat "a"), [1,2,3,1,2,3])).length == 2

## events

      {promise, reject, resolve} = require "when"
      {has} = require "./object"
      events = Method.create()
      isSource = compose isFunction, property "on"

      Method.define events, String, isSource, (name, source) ->
        events {name, end: "end", error: "error"}, source

      Method.define events, Object, isSource, (map, source) ->

        {name, end, error} = map
        done = false
        pending = []
        resolved = []

        enqueue = (x) ->
          if pending.length == 0
            resolved.push x
          else
            p = pending.shift()
            x.then(p.resolve).catch(p.reject)

        dequeue = ->
          if resolved.length == 0
            if !done
              promise (resolve, reject) -> pending.push {resolve, reject}
            else
              resolve {done}
          else
            resolved.shift()

        source.on name, (ax...) ->
          value = if ax.length < 2 then ax[0] else ax
          enqueue resolve {done, value}
        source.on end, (error) -> done = true
        source.on error, (error) -> enqueue reject error

        asyncIterator dequeue

      events = curry binary events

      context.test "events", ->
        {createReadStream} = require "fs"
        i = events "data", createReadStream "test/lines.txt"
        assert (yield i()).value.toString() == "one\ntwo\nthree\n"
        console.log yield i()
        # assert (yield i()).done


## stream

Turns a stream into an iterator function.

      stream = events "data"

      context.test "stream", ->
        {createReadStream} = require "fs"
        i = stream createReadStream "test/lines.txt"
        assert ((yield i()).value == "one\ntwo\nthree\n")
        assert (yield i()).done

## split

Given a function and an iterator, produce a new iterator whose values are delimited based on the given function.

      split = Method.create()

      Method.define split, Function, $,
        (f, x) -> split f, (iteratorFunction x)

      Method.define split, Function, isIteratorFunction, (f, i) ->
        lines = []
        remainder = ""
        iterator ->
          if lines.length > 0
            value: lines.shift(), done: false
          else
            {value, done} = i()
            if !done
              [first, lines..., last] = f value
              first = remainder + first
              remainder = last
              {value: first, done}
            else if remainder != ""
              value = remainder
              remainder = ""
              {value, done: false}
            else
              {done}

      Method.define split, Function, isAsyncIteratorFunction, (f, i) ->
        lines = []
        remainder = ""
        iterator ->
          if lines.length > 0
            value: lines.shift(), done: false
          else
            {value, done} = yield i()
            if !done
              [first, lines..., last] = f value
              first = remainder + first
              remainder = last
              {value: first, done}
            else if remainder != ""
              value = remainder
              remainder = ""
              {value, done: false}
            else
              {done}

      split = curry binary split
      context.test "split", ->
         i = split ((x) -> x.split("\n")), ["one\ntwo\n", "three\nfour"]
         assert i().value == "one"
         assert i().value == "two"
         assert i().value == "three"
         assert i().value == "four"
         assert i().done

## lines

      lines = split (s) -> s.toString().split("\n")

      context.test "lines", ->
        {createReadStream} = require "fs"
        i = lines stream createReadStream "test/lines.txt"
        assert ((yield i()).value) == "one"
        assert ((yield i()).value) == "two"
        assert ((yield i()).value) == "three"
        assert ((yield i()).done)

---

      module.exports = {isIterable, isAsyncIterable,
        iterator, isIterator, isAsyncIterator,
        iteratorFunction, isIteratorFunction, isAsyncIteratorFunction,
        collect, map, each, fold, reduce, foldr, reduceRight,
        select, reject, filter, any, all,
        zip, assoc, project, flatten, compact, partition,
        sum, average, join, delimit,
        where,
        take, takeN,
        events, stream, lines, split}
