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

The last of our setup is a helper function, `done`. This takes a value object and evalutes to true if the `done` property is `true`.

      done = (v) -> v.done == true

## repeat

Analogous to `wrap`for an iterator. Always produces the same value `x`.

      repeat = (x) -> -> done: false, value: x

## collect

      {Method} = require "./multimethods"
      collect = Method.create
        description: "Collect an iterator's values into an array"
        default: (x) -> collect (iteratorFunction x)

      Method.define collect, isIteratorFunction,
        (i) -> value until (done {value} = i())

      {async} = require "./generator"
      Method.define collect, isAsyncIteratorFunction,
        async (i) -> value until (done {value} = yield i())

      context.test "collect", ->
        {first} = require "./array"
        assert (first collect [1..5]) == 1

## each

      each = Method.create
        description: "Apply the given function to each value in an iterator
                      and returns the resulting array"
        default: (f, x) -> each f, (iteratorFunction x)

      Method.define each, Function, isIteratorFunction,
        (f, i) -> (f value) until (done {value} = i())

      Method.define each, Function, isAsyncIteratorFunction,
        async (f, i) -> (f value) until (done {value} = yield i())

      {curry, binary} = require "./core"
      each = curry binary each

      context.test "each", ->
        {last} = require "./array"
        assert (last each ((x) -> x + 1), [1..5]) == 6

## map

      map = Method.create
        description: "Return a new iterator that will apply the given function
                      to each value produced by the iterator"

      Method.define map, Function, (-> true),
        (f, x) -> map f, (iteratorFunction x)

      do (done) ->

        Method.define map, Function, isIteratorFunction, (f, i) ->
          iterator ->
            {done, value} = i()
            if done then {done} else {done, value: (f value)}

        Method.define map, Function, isAsyncIteratorFunction, (f, i) ->
          iterator ->
            {done, value} = yield i()
            if done then {done} else {done, value: (f value)}

        map = curry binary map

      context.test "map", ->
        i = map Math.sqrt, [1, 4, 9]
        assert i().value == 1
        assert i().value == 2
        assert i().value == 3
        assert i().done

## fold/reduce

      {curry, ternary} = require "./core"
      fold = Method.create
        description: "Given function and an initial value, reduce an iterator
                      to a single value, ex: sum a list of integers"
        default: (x, f, y) -> fold x, f, (iteratorFunction y)

      Method.define fold, (-> true), Function, isIteratorFunction,
        (x, f, i) ->
          (x = (f x, value)) until (done {value} = i())
          x

      Method.define fold, (-> true), Function, isAsyncIteratorFunction,
        async (x, f, i) ->
          (x = (f x, value)) until (done {value} = yield i())
          x

      reduce = fold = curry ternary fold

      {add} = require "./numeric"
      context.test "fold/reduce", ->
        sum = fold 0, add
        assert (sum [1..5]) == 15

## foldr/reduceRight

      {curry, ternary} = require "./core"
      foldr = Method.create
        description: "Given function and an initial value, reduce an iterator
                      to a single value, ex: sum a list of integers, starting
                      from the right, or last, value"
        default: (x, f, y) -> foldr x, f, (iteratorFunction y)

      Method.define foldr, (-> true), Function, isIteratorFunction,
        (x, f, i) -> (collect i).reduceRight(f, x)

      Method.define foldr, (-> true), Function, isAsyncIteratorFunction,
        async (x, f, i) -> (yield collect i).reduceRight(f, x)

      reduceRight = foldr = curry ternary foldr

      {add} = require "./numeric"
      context.test "foldr/reduceRight", ->
        assert (foldr "", add, "panama") == "amanap"

## select/filter

      select = Method.create
        description: "Given a function and an iterator, use the function as a
                      filter to select values from those produced by the
                      iterator"
        default: (f, x) -> select f, (iteratorFunction x)

      do (done) ->

        Method.define select, Function, isIteratorFunction,
          (f, i) ->
            done = true
            iterator ->
              found = false
              until found || done
                {done, value} = i()
                found = (!done && (f value))
              if done then {done} else {value, done}

        Method.define select, Function, isIteratorFunction,
          (f, i) ->
            done = false
            iterator ->
              found = false
              until found || done
                {done, value} = yield i()
                found = (!done && (f value))
              if done then {done} else {value, done}

      {binary, curry} = require "./core"
      select = filter = curry binary select

      context.test "select", ->
        {odd} = require "./numeric"
        i = select odd, [1..9]
        assert i().value == 1
        assert i().value == 3

## reject

      {negate} = require "./logical"
      reject = curry (f, i) -> select (negate f), i

      context.test "reject", ->
        {odd} = require "./numeric"
        i = reject odd, [1..9]
        assert i().value == 2
        assert i().value == 4

## any

      any = Method.create
        description: "Given a function and an iterator, return true if
                      any value produced by the iterator satisfies the
                      function, acting as a filter"
        default: (f, x) -> any f, (iteratorFunction x)

      do (done) ->
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

      all = Method.create
        description: "Given a function and an iterator, return true if the
                      function returns true for all the values produced by the iterator"
        default: (f, x) -> all f, (iteratorFunction x)

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

      zip = Method.create
        description: "Given two iterators, combine them with the given function
                      into a single iterator"
        default: (f, x, y) -> zip f, (iteratorFunction x), (iteratorFunction y)

      Method.define zip, Function, isIteratorFunction, isIteratorFunction,
        (f, i, j) ->
          iterator ->
            if !(done x = i()) && !(done y = j())
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

#
# ## unzip
#
#       _unzip = ([ax, bx], [a, b]) ->
#         ax.push a
#         bx.push b
#         [ax, bx]
#
#       unzip = (i) -> fold [[],[]], _unzip, i
#
#       context.test "unzip", ->
#         {first} = require "./array"
#         {toString} = require "./string"
#         assert (fold "", add, first collect unzip zip "panama", "canary") ==
#           "panama"
#
# ## assoc
#
#       {first, second} = require "./array"
#       assoc = async (i) ->
#         do (i = iterate i) ->
#           result = {}
#           until done
#             {done, value} = yield i()
#             result[first value] = (second value) if value?
#           result
#
#       context.test "assoc", ->
#         assert (yield assoc [["foo", 1], ["bar", 2]]).foo == 1
#
#
# ## project
#
#       {property} = require "./object"
#       {w} = require "./string"
#       project = curry binary async (p, i) -> yield map (property p), i
#
#       {third} = require "./array"
#       context.test "project", ->
#         assert (third collect project "length", w "one two three") == 5
#
#
# ## flatten
#
#       flatten = (ax) ->
#         fold [], ((r, a) ->
#           if a.forEach?
#             r.push (flatten a)...
#           else
#             r.push a
#           r), ax
#
#       context.test "flatten", ->
#         do (data = [1, [2, 3], 4, [5, [6, 7]]]) ->
#           assert (second yield flatten data) == 2
#
#
# ## compact
#
#       {isDefined} = require "./type"
#       compact = select isDefined
#
#       context.test "compact", ->
#         assert (second collect compact [1, null, null, 2]) == 2
#
#
# ## partition
#
#       partition = curry (n, i) ->
#         i = iterate i
#         done = false
#         async ->
#           batch = []
#           until done || batch.length == n
#             {done, value} = yield promise i()
#             batch.push value unless done
#           if done then {done} else {value: batch, done}
#
#       context.test "partition", ->
#         {first, second} = require "./array"
#         assert (first second collect partition 2, [0..9]) == 2
#
# ## take
#
#       take = curry (n, i) ->
#         i = iterate i
#         done = false
#         async ->
#           unless done || n-- == 0
#             {done, value} = yield promise i()
#             if done then {done} else {done, value}
#           else
#             done = true
#             {done}
#
#       {last} = require "./array"
#       context.test "take", ->
#         assert (last collect take 3, [1..5]) == 3
#
# ## leave
#
#       leave = curry binary async (n, i) ->
#         (yield collect i)[0...-n]
#
#       context.test "leave", ->
#         assert (last leave 3, [1..5]) == 2
#
# ## skip
#
#       skip = curry binary async (n, i) ->
#         (yield collect i)[n..-1]
#
#       context.test "skip", ->
#         assert (first skip 3, [1..5]) == 4
#
# ## sample
#
# Sample 1% of the integers up to 1 million. Take the first 500.
#
# ```coffee
# collect take 500, sample 0.01, [0..1e6]
# ```
#
#       sample = curry (n, i) ->
#         _sample = -> Math.random() < n
#         select _sample, i
#
#       context.test "sample"
#
# ## sum
#
# Sum the numbers produced by a given iterator.
#
# This is here instead of in [Numeric Functions](./numeric.litcoffee) to avoid forward declaring `fold`.
#
#       {add} = require "./numeric"
#       sum = fold 0, add
#
#       context.test "sum", ->
#         assert (sum [1..5]) == 15
#
# ## average
#
# Average the numbers producced by a given iterator.
#
# This is here instead of in [Numeric Functions](./numeric.litcoffee) to avoid forward declaring `fold`.
#
#       average = (i) ->
#         j = 0
#         f = (r, n) -> r += ((n - r)/++j)
#         fold 0, f, i
#
#       context.test "average", ->
#         assert (average [1..5]) == 3
#         assert (average [-5..-1]) == -3
#
# ## join
#
# Concatenate the strings produced by a given iterator. Unlike `Array::join`, this function does not delimit the strings. See also: `delimit`.
#
# This is here instead of in [String Functions](./string.litcoffee) to avoid forward declaring `fold`.
#
#       {cat} = require "./array"
#       join = fold "", add
#
#       context.test "join", ->
#         {w} = require "./string"
#         assert (join w "one two three") == "onetwothree"
#
# ## delimit
#
# Like `join`, except that it takes a delimeter, separating each string with the delimiter. Similar to `Array::join`, except there's no default delimiter. The function is curried, though, so calling `delimit ' '` is analogous to `Array::join` with no delimiter argument.
#
#       delimit = curry (d, i) ->
#         f = (r, s) -> if r == "" then r += s else r += d + s
#         fold "", f, i
#
#       context.test "delimit", ->
#         {w} = require "./string"
#         assert (delimit ", ", w "one two three") == "one, two, three"
#
# ## where
#
# Performs a `select` using a given object object. See `query`.
#
#       {query} = require "./object"
#       {cat} = require "./array"
#       where = curry (example, i) ->
#         select (query example), i
#
#       context.test "where", ->
#         assert (collect where ["a", 1],
#           (zip (repeat "a"), [1,2,3,1,2,3])).length == 2
#
#
# ## split
#
# Iterator transformation.
#
#       split = Method.create
#         description: "Given a function and an iterator, produce a new
#                       iterator whose values are delimited based on the
#                       given function"
#         default: (f, i) -> split f, (iteratorFunction i)
#
#       do (done) ->
#
#         Method.define split, Function, isIteratorFunction, (f, i) ->
#           lines = []
#           done = false
#           iterator ->
#             if done
#               {done}
#             else if lines.length > 0
#               lines.shift()
#             else
#               {value, done} = i()
#               if done
#                 {done}
#               else
#                 [first, values..., last] = f value
#                 if remainder?
#                   # okay, how do we do this w/o cheating
#                   first = remainder + first
#                   remainder = last
#                 lines = {value, done} for value in values
#                 {value: first, done}
#
#       context.test "split"
#
# ## lines
#
#       lines = split (s) -> s.split("\n")
#
#       context.test "lines", ->
#         {stream} = require "./fs"
#         {createReadStream} = require "fs"
#         i = lines stream createReadStream "test/lines.txt"
#         assert ((yield i()).value) == "one"
#         assert ((yield i()).value) == "two"
#         assert ((yield i()).value) == "three"
#         assert ((yield i()).done)
#
#
#
#
# ---
#
#       module.exports = {isIterable, iterator, isIterator, iterate,
#         collect, map, fold, reduce, foldr, select, reject, any, all,
          zip, unzip,
#         assoc, project, flatten, compact, partition, take, leave, skip,
#         sample, sum, average, join, delimit, where, repeat}

      module.exports = {isIterable, isAsyncIterable,
        isIterator, isAsyncIterator, iterator, iteratorFunction,
        isIteratorFunction, isAsyncIteratorFunction,
        collect, map, fold, reduce, foldr, reduceRight,
        select, reject, filter,
        any, all,
        zip}
