Iterators are a new feature in ES6 JavaScript. The _iterator protocol_ is very simple. There is a special property of an object that allows you to obtain an iterator for using it. This property returns an iterator object. The iterator object has a `next` method, which returns value wrapper objects. The value can be accessed with the `value` property. A `done` property indicates whether the iterator can produce any additional values.

In ES6, this is used to implement iterator-aware language constructs, such as `for` loops. In a functional style however, we may not want to use these constructs. We can compose, curry, and otherwise combine functions, which we cannot do with `for` loops directly. What we'd like ideally is an iterator function of some kind that works like the `next` method. This is fairly easy: we simply wrap an iterator object within a function. If we implement our collection-oriented functions (like `map` or `select`) in terms of iterators (or at least allow for that) we get the best of both worlds.

Remember though, iterators return value wrappers with a `done` property, not the values themselves. This means that functions that are dealing with iterator functions need to be aware of that. It also creates a rather awkward conflation of two separate things: checking to see if an iterator is done, and getting the next value from it. The JavaScript language attempts to resolve this issue for us by building awareness of this convention into its looping constructs. This hasn't been incorporated into CoffeeScript. This doesn't cause a problem when dealing with collection functions that accept iterators. But it doesn't make the implementation of those functions more awkward, along with scenarios where the collection functions aren't adequate for some reason.

There's an additional complication when using asynchronous iterators. A stream could be modeled in this fashion. Our first inclination might be to model streams as an iterator whose values are promises. However, we don't know whether the iterator is finished until after the last promise resolves. Consequently, the iterator function can't return a value wrapper, but a promise. When the promise resolves, if the stream is finished, it will set the `done` attribute of the value wrapper to true. Unfortunately, this means our iterator function is no longer really an iterator function because it doesn't return value wrappers.

There are other conventions we could adopt. We could define a special `done` value that is returned once an iterator has exhausted itself. However, in principle this is identical to value wrappers. We could instead make `done` a property of the iterator function. This might make for cleaner code in the synchronous case, but we run into a problem in the asynchronous case since `done` can't be a boolean because we can't set it until we're already into the next iteration, and it can't be a promise or it would block the iteration entirely. So it's best to stick with value-wrappers.

That leaves us with no choice but to define a second type of iterator function that returns promises. These promises resolve into value wrappers. With a little helper function—we'll call it `done` for the moment—we can even avoid the tedious details of dealing with the value wrapper. Here's the synchronous version of looping with a synchronous iterator function.

```coffee
until ({value} = (done it()))
  # do something with value...
```

The nice thing about this is that the async version is almost identical.

```coffee
until ({value} = (done yield it()))
  # do something with value...
```

In this context, let's consider `map`. This function will take a transformation function and an iterator return another iterator that applies the transformation function to each value returned by the original iterator.

The synchronous version is straightforward.

```coffee
map = (fn, it) ->
  ->
    {value, done} = it()
    if done then {done} else {done, value: (fn value)}
```

The asynchronous version, where we only consider the possibly that the iterator itself is asynchronous, isn't much different.

```coffee
map = (fn, it) ->
  async ->
    {value, done} = yield it()
    if done then {done} else {done, value: (fn value)}
```

What's interesting at this point is that we're already producing promises. So taking an asynchronous iterator makes the `map` function itself an asynchronous iterator. At this point, we've got nothing to lose by using `yield` with the transformation function, just in case it's asynchronous, too.

```coffee
map = (fn, it) ->
  async ->
    {value, done} = yield it()
    if done then {done} else {done, value: (yield fn value)}
```

This is more or less what we have in Fairmont right now. Unfortunately, it turns _all_ iterators into asynchronous iterators. In fact, Fairmont's underlying assumption is basically that all iterators are asynchronous.

This is a bit tedious because there's a lot of overhead associated with managing yield expressions. Can we use multimethods here to simplify thing?

```coffee
map = Method.create()

Method.define map, Function, Function, (fn, it) ->
  ->
    {value, done} = it()
    if done then {done} else {done, value: (fn value)}

Method.define map, Function, isAsynchronousIterator, (fn, it) ->
  async ->
    {value, done} = yield it()
    if done then {done} else {done, value: (yield fn value)}

map = curry binary map
```

So this is pretty easy to do, provided that we can define a predicate to detect asynchronous iterator functions. We could, in theory, do this by simply flagging the functions as such. We already do this already for iterator functions so that we can avoid redundantly wrapping iterator functions. We do this by making the iterator functions themselves iterators. This seems entirely within the rules—we aren't doing anything that isn't consistent with the iterator protocol. But adding a new property to functions to identify them as asynchronous is a different story. In addition, unlike synchronous iterator functions, asynchronous iterator functions are not isomorphic to iterators. The stream scenario is the proof of that. We _could_ therefore make use of the fact that asynchronous iterator functions are _not_ iterators.

I don't really like any of this. It seems that we ought to be able to just use any ordinary function that returns value wrappers. Or for that matter, any ordinary function at all, like, say, `Math.random()`. On the other hand, it's easy to have another function that transforms an ordinary function into an iterator function. We tried to do that in Fairmont already and, although it didn't really work, it was the right idea. In this context, an iterator function was easy to check for: it's an iterator whose `next` function is equal to itself. So I can talk myself into iterator functions being special.

Logically, then, why can't asynchronous iterator function be special? And if they're special, why can't we identify them as a type? And thus have a predicate function for them? Assuming for a moment that would be okay, how would we do this? My first thought is to have something analagous to `next`, like `nextPromise`. So `isAsynchronousIteratorFunction` would be defined as:

```coffee
isAsynchronousIteratorFunction = (it) -> it.nextPromise == it
```

At this point, it seems worth a quick digression about the word _iterator_. An iterator in JavaScript, it seems fair to say, means an object with a `next` method. Saying _itererator function_ is sort of a mouthful, but we can't just say _iterator_ because that already has a meaning. This caused some troulbe in the current implementation because it isn't clear when _iterator_ means an function, and when it means an object. As far as terminology goes, it's tricky. _Enumerator_ seems like a term introduced just to have another term because it's so similar to _iterator_. And this concept is _so_ similar to an iterator, it feels like the term should be derived somehow from it.

We create iterator functions via a closure over the iterator. As a result, it's basically a wrapped iterator. In the context of reducers and transducers, however, we could consider such a function to be a _producer_. This is very similar to a _generator_. But a generator is much more specific thing. It's a function that, when invoked, produces an iterator. So a generator is a kind of producer. A producer is just a function that produces values. In Fairmont, producers are often used to wrap iterators.

(This, by the way, raises a somewhat mind-bending possibility of converting a generator function into a producer function. But let's put that aside for the moment.)

The thing is, if we decide that producers are this general idea, then we have the same problem we had before. We end up wanting to say _iterator producer_ or something like that. Because of the `next` (or `nextPromise` attribute). However, we can define this however we like. We can say that producers are not simply functions that produce a value, but that they specifically wrap iterators. This seems like too much, though, for such an elegant name. What if we simply dropped the idea that a producer can be mapped back into an iterator? It's a meaningless convenience for asynchronous iterators anyway, since there is no asynchronous iterator protocol.

This makes us want to be able to check the type of a function. We'd like to be able to say something like `p instanceof Producer`. Unfortunately, JavaScript apparently makes it impossible do this. Even if you extract the body of a function as a string and pass it into a constructor of a class that extends `Function`, `instanceof` still ignores everything and thinks of the function as being an instance of `Function`.

```
coffee> class A extends Function
{ [Function: A] __super__: [Function: Empty] }
coffee> f = new A "return 'hello'"
[Function]
coffee> f()
'hello'
coffee> f instanceof A
false
coffee> f.constructor
[Function: Function]
```

At least as far as I'm aware, there's no way to create function for which `instanceof` will return true for any constructor function other than `Function.` So: we can't use the type system to identify producers. Therefore we must somehow tag the function so we can recognize it as a producer. This is frustrating because we'd love for this function to be considered a producer automatically:

```coffee
f = do (counter = 0) ->
  -> counter++
```

Instead, we need some sort of `create` function to ensure that the function is tagged correctly. And since we do need to tag it, we might as well do something useful. And allowing producers to act as iterators _is_ actually useful. So using `next` as the tag makes sense. And, for asynchronous producers, `nextPromise` makes sense as a matter of parallel construction.

And, to reiterate (sorry), the reason asynchronous producers don't have a `next` method is because they don't know if they're done when they produce the next value. So they cannot produce iterator value wrappers. Streams are the proof by example, as it were. We can't write this:

```coffee
done = false
until done
  {done, value} = it()
  # do something with value after yielding to it
```

because we can't know the value of `done` any more than we can know the value of `value`. If the stream's `end` event happens, we have no way to get that information back out to the loop.

Similarly, we can't set a property on the iterator. That's semantically the same problem: we'll end up in the next iteration of the loop even though we should be exiting it. Thus, we'll end up with some promised values that resolve, possibly quite unexpectedly, to `undefined`.

The only thing we can do is have _both_ the `value` and the `done` properties be promises. But that doesn't help preserve the built-in iteration constructs, because they're expecting a boolean, not a promise. So: there's no way to preserve the semantics of the iterator value wrappers for asynchronous producers. Consequently, we make the best of it by creating a parallel construction in `nextPromise`, which has same semantics, except that the value wrapper for the iterator is produced by the resolution of the promise.

---

As an aside, ES7 does include a proposal for asynchronous iterators. Unfortunately, at the moment, the interface for synchronous and asynchronous iterators is the same. I've filed a ticket asking about this. If ES7 were to adopt a specific interface, then we could follow that. For now, though, we're going to go with `nextPromise`.

---

With that out of the way, what remains is decide whether we want to commit to multimethods for dispatching, based on these predicates, which avoids introducing overhead for managing asynchronous functions when it isn't necessary. How much overhead is there?

To figure that out, let's go back to our counting producer. We can benchmark this simply enough by just defining a trivial function and comparing it to the same async version. The difference appears to be about four-thousand percent. That is, the async version is 400 times slower. And that doesn't count the overhead associated with yielding to the result, just the yield within the function.

It's safe to say that using async unnecessarily is bad.

Compare that to the benchmarks for multimethods. For a trivial predicate function, the performance is about a hundred times slower. In theory, therefore, we pick up a gain of about four hundred percent.

Still, that's not super encouraging. At best, we're going to still be a 100 times slower than if we simply didn't allow for asynchronous iterators.

Which is a rather significant take away. The most significant attempts to write collection functions for JavaScript don't even address asynchronous iteration. In fact, they don't address iterators at all. The few libraries that focus on the latter ignore the former, probably because we don't have asynchronous iterators yet. But we're going to, and we're going to need collection operators that support them. Without it costing a hundred-fold reduction in performance.

---

If not multimethods…what?

One obvious answer is methods with different names, which is horrifying. Another, which is more appealing is to simply hand-code the difference. We don't _need_ to use generator functions. We can just return promises. This is basically what we did with composition. Composition involving functions that return promises yields functions that also return promises.

In this case, any time we get a value back from an iterator, we simply check if it's a promise. If it is, we return a promise, too, based on that promise.

```coffee
if r.then?.call? then r.then ({value, done}) -> # ...
```

The basic idea is just like composition—you automatically turn an iterator into an async iterator if you pass it one to begin with. So for `take`, if we `take` from a `stream` iterator, the resulting iterator automatically becomes an asynchronous iterator.

One thing I really like about this approach is that we no longer need a way to tag asynchronous iterators. Or iterators at all. We can, if only because making it possible to use Fairmont producers as iterators, so you don't have to worry about whether you're using Fairmont or some other iterator-based library (or language construct).

Let's consider how `collect` works with this approach. First, let's just implement the synchronous version.

```coffee
collect = (it) -> value until done {value} = it()
```

Unfortunately, this gets quite a bit messier when we add support for promises. Let's implement support for asynchronous iterators by themselves first.

```coffee
collect = (it) ->
  promise (resolve) ->
    values = []
    do f = ->
      it()
      .then({done, value}) ->
        if done
          resolve values
        else
          values.push value
      f()
```

This is obviously a completely different algorithm, one that intrinsically must involve callbacks. Without a predicate to determine which version to use, we have to wait until we get the first value. This isn't exactly what we were hoping for. Compare this to what we have with some help from generators.

```coffee
collect = async (it) -> value until done {value} = yield it()
```

This has the further drawback of require all collection functions to effectively culminate in some form of `yield` expression, even when there's no reason for it. This can be isolated, though, so that we return a promise instead. To see how this works, we'll pretend for a moment that we have a way to identify synchronous iterator functions versus asynchronous iterator functions.

```coffee
collect = (it) ->
  if isAsynchronousIteratorFunction it
    call -> (value until done {value} = yield it())
  else (value until done {value} = it())

```

This is much better—it's fast for the synchronous case, but still slower than necessary for the asynchronous case. However, the latter difference is going to be a lot less than the hundred fold increases we were seeing before, because we're going to have a bunch of function call overhead one way or another. This is an optimization we can live without for now.

---

With a nice little `prepend` helper, we can do this without type-checking.

```coffee
prepend = (x, it) ->
  first = true
  ->
    if first
      x
    else
      first = false
      it()
```

With this, we can implement `peek`.

```coffee
peek = (it) ->
  x = it()
  [ x, (prepend x, it) ]
```

Which now makes it possible for us to implement collect like this:

```coffee
collect = (it) ->
  [x, it] = peek it
  if isPromise x
    call -> (value until done {value} = yield it())
  else
    (value until done {value} = it())
```

This is still a little bit messier then we'd like because we have two implementations, but the performance savings is so big it's worth it.

We can generalize this, though so that we don't have to hand-code this logic for every single function. This is a sort of specialized multimethod.

```coffee
p = ({sync, async}) ->
  f = (it) ->
    [x, it] = peek it
    if isPromise x then async it else sync it

collect = p
  sync: (it) -> value until done {value} = it()
  async: (it) -> value until done {value} = yield it()
```

This is kind of magic, because we only get asynchronous iterator functions if there's an asynchronous iterator function somewhere in the chain. Otherwise, we get the normal synchronous version.

---

Still to go: transducers. I don't think we need them because of the way our iterator functions already work. Perhaps I'm missing something here, but building up composable iterators from functions just seems to do everything we need to do, and it does it in a way that's easy to reason about and consistent with the direction of the language.

And with `prepend` and `peek`, we don't even need tags. And we can use whatever ES7 will use, so that our iterator functions just work, regardless of context.
