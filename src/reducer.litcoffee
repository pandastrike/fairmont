# Reducer Functions

Some functions _reduce_ an iterator into another value. Once a reduce function is introduced, the associated iterator functions will run.

    {isIterable, isAsyncIterable, iterator, isIterator, isAsyncIterator,
      isIteratorFunction, isAsyncIteratorFunction,
      iteratorFunction} = require "./iterator"

    {Method} = require "./multimethods"
    {isDefined} = require "./type"
    {async} = require "./async"
    {negate} = require "./logical"

## fold/reduce

Given an initial value, a function, and an iterator, reduce the iterator to a single value, ex: sum a list of integers.

    {curry, ternary} = require "./core"
    fold = Method.create()

    Method.define fold, (-> true), Function, isDefined,
      (x, f, y) -> fold x, f, (iteratorFunction y)

    Method.define fold, (-> true), Function, isIteratorFunction,
      (x, f, i) ->
        loop
          {done, value} = i()
          break if done
          x = f x, value
        x

    Method.define fold, (-> true), Function, isAsyncIteratorFunction,
      async (x, f, i) ->
        loop
          {done, value} = yield i()
          break if done
          x = f x, value
        x

    reduce = fold = curry ternary fold

## foldr/reduceRight

Given function and an initial value, reduce an iterator to a single value, ex: sum a list of integers, starting from the right, or last, value.

    {curry, ternary} = require "./core"
    foldr = Method.create()

    Method.define foldr, (-> true), Function, isDefined,
      (x, f, y) -> foldr x, f, (iteratorFunction y)

    Method.define foldr, (-> true), Function, isIteratorFunction,
      (x, f, i) -> (collect i).reduceRight(f, x)

    Method.define foldr, (-> true), Function, isAsyncIteratorFunction,
      async (x, f, i) -> (yield collect i).reduceRight(f, x)

    reduceRight = foldr = curry ternary foldr

## collect

Collect an iterator's values into an array.

    {push} = require "./array"
    collect = (i) -> reduce [], push, i

## each

Apply a function to each element but discard the results. This is a reducer because there isn't any point in having an iterator function that simply discards the value from another iterator. Basically, use `each` when you want to reduce an iterator without taking up any additional memory.

    each = curry (f, i) ->
      g = (_, x) -> (f x); _
      reduce undefined, g, i

## any

Given a function and an iterator, return true if the given function returns true for any value produced by the iterator.

    any = Method.create()

    Method.define any, Function, isDefined, (f, x) -> any f, (iteratorFunction x)

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

## all

Given a function and an iterator, return true if the function returns true for all the values produced by the iterator.

    all = Method.create()

    Method.define all, Function, isDefined, (f, x) -> all f, (iteratorFunction x)

    Method.define all, Function, isIteratorFunction,
      (f, i) -> !any (negate f), i

    Method.define all, Function, isAsyncIteratorFunction,
      async (f, i) -> !(yield any (negate f), i)

    all = curry binary all

## zip

Given a function and two iterators, return an iterator that produces values by applying a function to the values produced by the given iterators.

    zip = Method.create()

    Method.define zip, Function, isDefined, isDefined,
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

## unzip

    unzip = (f, i) -> fold [[],[]], f, i

## assoc

Given an iterator that produces associative pairs, return an object whose keys are the first element of the pair and whose values are the second element of the pair.

    {first, second} = require "./array"
    assoc = Method.create()

    Method.define assoc, isDefined, (x) -> assoc (iteratorFunction x)

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

## flatten

    _flatten = (ax, a) ->
      if isIterable a
        ax.concat flatten a
      else
        ax.push a
        ax

    flatten = fold [], _flatten

## sum

Sum the numbers produced by a given iterator.

This is here instead of in [Numeric Functions](./numeric.litcoffee) to avoid forward declaring `fold`.

    {add} = require "./numeric"
    sum = fold 0, add

## average

Average the numbers producced by a given iterator.

This is here instead of in [Numeric Functions](./numeric.litcoffee) to avoid forward declaring `fold`.

    average = (i) ->
      j = 0 # current count
      f = (r, n) -> r += ((n - r)/++j)
      fold 0, f, i

## join

Concatenate the strings produced by a given iterator. Unlike `Array::join`, this function does not delimit the strings. See also: `delimit`.

This is here instead of in [String Functions](./string.litcoffee) to avoid forward declaring `fold`.

    {cat} = require "./array"
    join = fold "", add

## delimit

Like `join`, except that it takes a delimeter, separating each string with the delimiter. Similar to `Array::join`, except there's no default delimiter. The function is curried, though, so calling `delimit ' '` is analogous to `Array::join` with no delimiter argument.

    delimit = curry (d, i) ->
      f = (r, s) -> if r == "" then r += s else r += d + s
      fold "", f, i

---

    module.exports = {collect, each, fold, reduce, foldr, reduceRight,
      any, all, zip, unzip, assoc, flatten,
      sum, average, join, delimit}
