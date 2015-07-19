# Iterator Functions

Fairmont introduces the idea of _iterator functions_. Iterator functions are functions that wrap Iterators. Many builtin JavaScript types are iterable, such as Arrays, Strings, Maps, and so on.

Iterator functions are also iterators and iterable. So they can be used anywhere an iterable can be used (ex: in a JavaScript `for` loop). And just as iterators are iterable, so are iterator functions.

Fairmont also supports async iterators, which [are a proposed part of ES7][100]. Async iterators return promises that resolve to iterator value objects. Basically, they work just like normal iterators, except the values take an intermediate form of promises.

[100]:https://github.com/zenparsing/async-iteration/

Iterators allow us to implement lazy evaluation for collection methods. In turn, this allows us to compose some iterator functions without introducing multiple iterations. For example, we can compose `map` with `select` and still only incur a single traversal of the data we're iterating over.

Some functions _reduce_ an iterator into another value. Once a reduce function is introduced, the associated iterator functions will run.

Array functions are included here when they complement another iterator function that operate directly on an iterable. For example, `any` collects an iterator into a true or false value. However, `all`, by definition, must traverse the entire iterable to return a value. Arguably, it consequently belongs with the Array functions. We include it here since it complements `any`.

## isIterable

We want a simple predicate to tell us if something is an iterator. This is simple enough: it should have a `Symbol.iterator` property. However, generators in Node don't look like iterables (yet?). So we add that case.

    {isGenerator} = require "./type"
    isIterable = (x) -> (x?[Symbol.iterator]?) || (x? && isGenerator x)

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

If we don't have an iterable, we might have a function. In that case, we assume we're dealing with an iterator function that simply hasn't been properly tagged. (Or, put another way, that we're calling `iterator` specifically to tag it.)

    {isFunction} = require "./type"
    Method.define iterator, isFunction, (f) ->
      f.next = f
      f[Symbol.iterator] = -> @this
      f

The simplest case is to just call the iterator method on the value. We can do this when we have something iterable. We have sync and async variants. These are defined last to avoid infinite recursion.

    Method.define iterator, isIterable, (i) -> i[Symbol.iterator]()
    Method.define iterator, isAsyncIterable, (i) -> i[Symbol.asyncIterator]()

For the moment, generator functions in Node aren't iterables for some reason. So we'll add this case here for the moment.

    {isGenerator} = require "./type"
    Method.define iterator, isGenerator, (g) -> g()

(If what you want is an async iterator from a generator function, use `async` to adapt it into a function that returns promises first and then call `asyncIterator`.)

## asyncIterator

The `asyncIterator` function is analogous to the `iterator` function—it's job is to ensure that the object given as an argument is a proper asynchronous iterator.

    asyncIterator = Method.create()

    Method.define asyncIterator, isFunction, (f) ->
      f.next = f
      f[Symbol.asyncIterator] = -> @this
      f

You might think we should have a way to construct an async iterator directly from a generator function, but this is the kind of thing someone might do an accident, so we generate a type error instead.

## isIteratorFunction

We want to be able to detect whether we have an iterator function. Iterators that are also functions are iterator functions.

    {isFunction} = require "./type"
    isIteratorFunction = (f) -> (isFunction f) && (isIterator f)

## isAsyncIteratorFunction

This is the async variant of `isIteratorFunction`.

    isAsyncIteratorFunction = (f) -> (isFunction f) && (isAsyncIterator f)

## iteratorFunction

`iteratorFunction` takes a value and tries to return an `IteratorFunction` based upon it. We're using predicates here throughout because they have a higher precedence than `constructor` matches.

It might seem rather strange that there's no corresponding `asyncIteratorFunction`. This is because `iteratorFunction` already handles both cases. If you have an async iteratable or iterator, `iteratorFunction` will still return you something that satisfies `isAsyncIteratorFunction`.

If you want to _construct_ an async iterator function, use `asyncIterator` with a function that returns a promise.

    {Method} = require "./multimethods"
    iteratorFunction = Method.create()

If we get an iterable, we want an iterator for it, and then to turn that into an iterator function.

    {either} = require "./logical"
    Method.define iteratorFunction,
      (either isIterable, isAsyncIterable),
      (x) -> iteratorFunction iterator x

If we get an iterator as a value, we simply need to wrap it in a function that calls it's `next` method, and then call `iterator` on that. We define this after the method taking iterables, since iterators are iterables, and we want this function to have precedence.

    Method.define iteratorFunction,
      (either isIterator, isAsyncIterator),
      (i) -> iterator (-> i.next())

If given a function that isn't already an iterator (or an iterator function), we can convert that into an iterator function by simply calling `iterator` on the value, since it's already a function.

    {either} = require "./logical"
    {isFunction} = require "./type"
    Method.define iteratorFunction, isFunction, (f) -> iterator f

Now we can define the trivial case, where we already have an iterator function and just need to return it. This comes last so that it has the highest precedence, since iterator functions are both iterators and functions (and would thus match each of the previous rules and cause an infinite recursion).

    {either} = require "./logical"
    {identity} = require "./core"
    Method.define iteratorFunction,
      (either isIteratorFunction, isAsyncIteratorFunction),
      identity

## repeat

Analogous to `wrap`for an iterator. Always produces the same value `x`.

    repeat = (x) -> (iterator -> done: false, value: x)

We're going to use `isDefined` internally here to mean a wildcard value for purposes of argument matching.

    {isDefined} = require "./type"

## map

Return a new iterator that will apply the given function to each value produced by the iterator.

    map = Method.create()

    Method.define map, Function, isDefined,
      (f, x) -> map f, (iteratorFunction x)

    {async} = require "./async"
    {isPromise} = require "./type"
    Method.define map, Function, isPromise, async (f, p) ->
      map f, (yield p)

    Method.define map, Function, isIteratorFunction, (f, i) ->
      iterator ->
        {done, value} = i()
        if done then {done} else {done, value: (f value)}

    # TODO add check for promise values in other async iterators
    # TODO should sync iterators mutate into async iterators if the
    #      given function returns a promise?
    Method.define map, Function, isAsyncIteratorFunction, (f, i) ->
      asyncIterator async ->
        {done, value} = yield i()
        unless done
          value = f value
          if isPromise value
            value = yield value
        {done, value}

    {curry, binary} = require "./core"
    map = curry binary map

## select/filter

Given a function and an iterator, return an iterator that produces values from the given iterator for which the function returns true.

    select = Method.create()

    Method.define select, Function, isDefined,
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
        asyncIterator async ->
          loop
            {done, value} = yield i()
            break if done || (f value)
          {done, value}

    {binary, curry} = require "./core"
    select = filter = curry binary select

## reject

Given a function and an iterator, return an iterator that produces values from the given iterator for which the function returns false.

    {negate} = require "./logical"
    reject = curry (f, i) -> select (negate f), i

## project

    {property} = require "./object"
    {curry} = require "./core"
    project = curry (p, i) -> map (property p), i

## compact

    {isDefined} = require "./type"
    compact = select isDefined

## partition

    partition = Method.create()

    Method.define partition, Number, isDefined, (n, x) ->
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
      asyncIterator async ->
        batch = []
        loop
          {done, value} = yield i()
          break if done
          batch.push value
          break if batch.length == n
        if done then {done} else {value: batch, done}

## take

Given a function and an iterator, return an iterator that produces values from the given iterator until the given function returns false when applied to the given iterator's values.

    take = Method.create()

    Method.define take, Function, isDefined,
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

## takeN

Given an iterator, produces the first N values from the given iterator.

    takeN = do ->
      f = (n, i = 0) -> -> i++ < n
      (n, i) -> take (f n), i

## where

Performs a `select` using a given object object. See `query`.

    {query} = require "./object"
    where = curry (example, i) -> select (query example), i

## events

    {has} = require "./object"
    {compose} = require "./core"
    events = Method.create()
    isSource = compose isFunction, property "on"

    Method.define events, String, isSource, (name, source) ->
      events {name, end: "end", error: "error"}, source

    Method.define events, Object, isSource, (map, source) ->

        {promise, reject, resolve} = require "when"
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
        source.on end, (error) ->
          done = true
          enqueue resolve {done}
        source.on error, (error) -> enqueue reject error

        asyncIterator dequeue

    events = curry binary events

## stream

Turns a stream into an iterator function.

    stream = events "data"

## split

Given a function and an iterator, produce a new iterator whose values are delimited based on the given function.

    split = Method.create()

    Method.define split, Function, isDefined,
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
      asyncIterator async ->
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

## lines

    lines = split (s) -> s.toString().split("\n")

---

    module.exports = {isIterable, isAsyncIterable,
      iterator, isIterator, isAsyncIterator,
      isIteratorFunction, isAsyncIteratorFunction, iteratorFunction,
      repeat, map, select, reject, filter, project, compact,
      partition, where, take, takeN, events, stream, lines, split}
