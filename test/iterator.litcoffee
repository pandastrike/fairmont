# Collections Are Iterators, Values Are Promises

JavaScript, and even more so CoffeeScript, has a lot of competing programming styles. Object-oriented and functional styles are both possible. Callback-based interfaces compete with event-driven interfaces. And now, with ES6, iterators, generators, and promises are options.

With all these language features, it's easy to end up with competing styles, even within a single library. One of Fairmont's main goals is to encourage a more functional style. To get there, though, without sacrificing performance, turns out to be more difficult than it looks.

---

Suppose we want to read all the files in a given directory. This seems like a natural place for `map`.

Let's do a little bit of prep by loading up some helper functions.

    {call, async} = do ->
      {lift, call} = require "when/generator"
      {async: lift, call}
    {join} = require "path"

And, of course, some Fairmont goodness.

    {curry, compose, binary, read, readdir, map} = require "../src/index"
    join = curry binary join

We're going to need `assert` so we can verify our code as we go.

    assert = require "assert"

Finally, here's the code to load the files from a given directory using `map`.

    call ->
      path = "test"
      contents = map (compose read, (join path)), (yield readdir path)

This won't work, though, because `read` returns a promise. So we'll get an array of promises. Of course, we can yield on those.

      {first, is_string} = require "../src/index"
      assert is_string yield first contents

But that's a little unsatisfying.

There's another problem with our version of `map`, which is that, for large arrays, it's very inefficient. This is why libraries like `lazy.js` and `lodash` support lazy evaluation for functions that operate on a function.

We can see both of these problems more clearly if we imagine that, rather than the contents of the files, we only want the MD5 hash.

Our first thought might be to compose `md5` with `read`, but we can't do that because, again, read returns a promise, and we're not trying to MD5 a promise.

We could use two map operations and a promise function to wait until all the `read` promises have a resolved. But now we're making three passes across the initial array of pathnames, and creating intermediate arrays at each step.

That's probably okay for this simple case, but it would be nice not to have to ditch Fairmont every time we're dealing with large data sets. In fact, that's exactly when we'd like to have a nice library to help out.

---

Let's start with making composition more promise-friendly.

    promise = require "when"

    compose = (fx..., f) ->
      if fx.length == 0
        f
      else
        g = compose fx...
        async (ax...) -> yield promise g yield promise f ax...

The only troubing thing about this is that now composition always returns a function that returns a promise, which seems like overkill for composing, say, addition and multiplication.

Let's table that for the moment. We should test to make sure our promise-friendly composition works.

    {md5} = require "../src/index"
    hash_file = compose md5, read

    call ->
      hash = yield hash_file "./test/lines.txt"
      assert hash == "deed54b823522e0525693b090363f9df"

Let's update our original function to use `md5`.

    {all} = require "when"
    call ->
      path = "test"
      contents = map (compose md5, read, (join path)), (yield readdir path)
      assert "deed54b823522e0525693b090363f9df" in (yield all contents)

So far, so good. We can compose asynchronous functions alongside synchronous functions.

---

We can use iterators to implement lazy-evaluation. Let's start by making it easier to deal with iterators. Due to backwards compatibility issues, the iterator interface in JavaScript is pretty <del>awkward</del> bananas.

Let's start with a couple of functions to check whether a value is iterable or is already an iterator.

    is_iterable = (x) -> x[Symbol.iterator]?
    assert is_iterable [1, 2, 3]

    is_iterator = (x) -> x.next?

We'll make it easy to construct iterators, too. We'll make it idempotent so we don't have to put `is_iterator` checks in our code.

    iterator = (x) ->
      if is_iterable x
        x[Symbol.iterator]()
      else if is_iterator x
        x
      else
        throw new TypeError "Value is not an iterable or an iterator"

    {is_function} = require "../src/index"
    assert is_function (iterator [1, 2, 3]).next
    assert is_iterator (iterator [1, 2, 3])

That's handy, but we want to encourage a functional style, so we want an iterator function. That is, we want a function that, when you call it, gets us the next value, instead of requiring us to call `next` on an object. We want this function to be idempotent, too. However, that's a bit tricky, since we're just returning a function. We can't define the equivalent of `is_iterator` for an iterator function. We can't just check `is_function` because it's _possible_ that a function could be an iterable somehow. Besides which, we can't know for sure that an arbitrary function is iterator.

The solution is a bit clunky. We check for functions with zero length that aren't iterable or iterators. That's not a guarantee that it's an iterator function, but it's as close as we can get. We could tag the functions, but then we'd have to do that with any function that acts like an iterator function. Part of the beauty of functional programming is that everything is just functions. We don't want to create special kinds of functions unless we really need to. In this case, the worst that happens is a function returns an unexpected value. That's a possibility with any function, so we'll satisfy ourselves with just doing as much checking as we can.

    is_iterator_f = (x) ->
      (is_function x) && (x.length == 0) &&
        !((is_iterable x) || (is_iterator x))

    iterate = (x) ->
      unless is_iterator_f x
        do (it = iterator x) ->
          -> it.next()
      else
        x

    i = iterate [1, 2, 3]
    assert i().value == 1
    assert i().value == 2
    assert i().value == 3
    assert i().done

---

As an aside, why not use streams instead of iterators? Because we can model streams as iterators and iterators are much simpler.

Moreover, if we base our iterator interface on JavaScript's, we get support for all the JavaScript collection classes for free.

---

We can now implement a lazy `map`.

    map = curry (f, x) ->
      do (i = iterate x) ->
        ->
          {done, value} = i()
          unless done then {done, value: f value} else {done}

Our `map` function is now an iterator. Which is great, except it only works with one value at a time. Let's add a helper that collects the values from an iterator.

    {leave} = require "../src/index"

    collect = (i) ->
      leave 1,
        until done
          {done, value} = i()
          value

    mul = curry (x, y) -> x * y
    double = mul 2
    x = collect map double, [1,2,3]
    assert x[1] == 4

With our new lazy `map` function, we only make one pass through the data.

    call ->
      path = "test"
      contents = collect map (compose md5, read, (join path)),
        (yield readdir path)

But some of that efficiency is lost when we have to convert the promises back to values.

      assert "deed54b823522e0525693b090363f9df" in (yield all contents)

---

What if our iterator functions returned promises? We can then get the values in our `collect` function.

    iterate = (x) ->
      unless is_iterator_f x
        do (it = iterator x) ->
          async ->
            {done, value} = it.next()
            {done, value: yield promise value}
      else
        x

    call ->
      i = iterate [1, 2, 3]
      assert is_iterator_f i
      assert (yield i()).value == 1
      assert (yield i()).value == 2
      assert (yield i()).value == 3
      assert (yield i()).done

We need to update `map` and `collection` to `yield` appropriately.


    map = (f, x) ->
      do (i = iterate x) ->
        async ->
          {done, value} = yield i()
          unless done then {done, value: yield promise f value} else {done}

    collect = async (i) ->
      leave 1,
        until done
          {done, value} = yield i()
          value

    x = collect map double, [1,2,3]
    assert x[1] == 4

And now, finally, we can get rid of that call to `all` that was raining on our efficiency parade.

    call ->
      path = "test"
      contents = yield collect map (compose md5, read, (join path)),
        (yield readdir path)
      assert "deed54b823522e0525693b090363f9df" in contents

We're now composing asynchronous functions and doing lazy evalution to avoid unnecessary passes through the data. We put a filename in one end and we get an MD5 hash out of the other end.

With a little bit of reflection, it's clear that we're talking about two fundamental principles here:

* Values are always wrapped within promises

* Collections are always wrapped within iterators

This adds some overhead. For example, `md5` doesn't return a promise, but `compose` has to wrap it in a promise, just in case. It also adds some complexity. Is it worth it?

Consider how this same function would look if we just wrote it out by hand.

    call ->
      path = "test"
      contents = for filename in yield readdir path
        md5 yield read join path, filename
      assert "deed54b823522e0525693b090363f9df" in contents

From a complexity standpoint, it doesn't look like gained anything. Maybe we need a more complex example.

Suppose we ultimately want to create a dictionary of MD5 hashes to pathnames. Basically, a content-addressable index.

We're going to first need a lazy `zip` function, to zip together the hashes and the pathnames.

    zip = (i, j) ->
      i = iterate i
      j = iterate j
      async ->
        if (_i = yield i()).done || (_j = j()).done
          done: true
        else
          done: false, value: [_i.value, _j.value]

    call ->
      {second, third} = require "../src/index"
      assert (second third yield collect zip [1, 2, 3], [4, 5, 6]) == 6

Last, we need an `assoc` function that will convert this into an object.

    {first, second} = require "../src/index"
    assoc = async (i) ->
      do (i = iterate i) ->
        result = {}
        until done
          {done, value} = yield i()
          result[first value] = (second value) if value?
        result

    call ->
      assert (yield assoc [["foo", 1], ["bar", 2]]).foo == 1

We're now ready to put it all together.

    f = async (path) ->
      paths = yield readdir path
      yield assoc zip (map (compose md5, read, join path), paths), paths

    call ->
      assert (yield f "test")["deed54b823522e0525693b090363f9df"]?

Let's compare this to our inline version.

    g = async (path) ->
      contents = {}
      for filename in yield readdir path
        contents[md5 yield read join path, filename] = filename
      contents

    call ->
      assert (yield g "test")["deed54b823522e0525693b090363f9df"]?

Even with the added complexity of creating a dictory, our inline version is more concise and arguably mor expressive than the functional version. And this is _after_ distorting `compose` and `map` to work with iterators and promises.

Let's at least verify that using iterators has kept us from losing too much ground from a performance standpoint.

    {third} = require "../src/index"
    if (third process.argv) == "--benchmark"
      now = -> Date.now()
      benchmark = async curry (n, f) ->
        m = n
        start = now()
        yield f() until m-- is 0
        (now() - start)/n

      call ->
        console.log "Running benchmarks..."

        tf = yield benchmark 1000, -> f "test"

        tg = yield benchmark 1000, -> g "test"

Let's make sure we within at least 25% of the inline version's performance.

        assert (tf/tg - 1) < .25

We haven't gained much, if anything, in expressiveness, but, on the other hand, we haven't lost too much in performance. Still, that's a net loss, right?

I think the answer is that the functional version is just a bunch of function calls. The control flow is all within those functions. Whereas our inline version contains a loop and an assignment. The _cyclomatic_ complexity is higher, even if the code itself looks innocent.

If we run `coffeelint` on these two functions, we get a score of 1 for our functional version and 2 for the inline version. That is, the inline version is twice as complex, because of the loop.

Of course, that's still not very complex because this is still a relatively simple example. But imagine if this was consistent throughout a codebase. The implication is that there is half as much chance for errors.

This is the promise of functional programming. Not expressiveness, because CoffeeScript is already pretty expressive, but simplicity.

What we've accomplished here, with a little help from ES6, is to bring the simplificty of functional programming to efficient asynchronous operations on collections. We've done that without sacrificing expressiveness or performance (at least, not very much performance).

---

The next question is whether we want to create a separate family of promise-aware functions. Do we really want `compose` to be anything other than simple function composition? Our version here will still work for arbitrary functions, but the definition is a bit more complex than the conventional version. To compare and contrast, here's the conventional version:

    compose = (fx..., f) ->
      unless fx.length == 0
        g = compose fx...
        (ax...) -> g(f(ax...))
      else
        f

And here's the promise-aware version:

    compose = (fx..., f) ->
      if fx.length == 0
        f
      else
        g = compose fx...
        async (ax...) -> yield promise g yield promise f ax...

It's not really _that_ bad, but the yielding and promising does add some extra overhead. One possibility would be to introduce a second function. Let's call it `compose_p`, where the `p` stands for promise-aware. However, once we do that, do we also have `map_i` (for iterator-aware) and `zip_i` and so on?

Another option is to do what `when` does and have the names be based on which path you use in  `require` (or have the return value from `require` be an object whose properties are the different variations).

(Of course, you're free to name them whatever you want, but that can get a little bit tedious after awhile.)

I think the right answer is just to concede that JavaScript, as of ES6, is going to become promise and iterator-centric. Values are always promises and collections are always iterators. Or, perhaps more properly, promises are atom monads and iterators are collection monads.

Thus, `compose`, for JavaScript, should be promise-aware, just as `map` should operate on iterators. You can do it another way if you want, but that's the way Fairmont does it. And this is part of what makes Fairmont unique.
