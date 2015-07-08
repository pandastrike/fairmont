A lot of has been written about even-driven programming. Event-driven frameworks often use method chaining to specify how to respond to events.

    select "li > a.show.button"
    .on "click"
    .property "href"
      .toResource()
      .GET()
      .on "200"
      .on "ready"
        .property "body"
          .parseJSON()
            .bind detailView
            .on "change"
          .end()
        .end()
      .PUT detailView.data

This is a completely made up and probably impractical example. But the general idea is to (a) think in terms of event streams; (b) to think in terms of bindings between events and data (and vice-versa); and (c) to express all this as declaratively as possible.

The first thing I think of is that this should be written in a functional style.

    bind detailView,
      parseJSON property "body",
        on "ready",
          on "200",
            GET (toResource (property "href",
              on "click", select "li > a.show.button"))

I'll stop here because it's obviously getting a little ridiculous. Or maybe it isn't, but we certainly need to consider what we're doing here.

To begin with, apparently, lots of things either take or return promises or streams of some kind. Let's just start with this little expression.

    on "click", select "li > a.show.button"

Let's assume for a moment that `on` is a function that takes an event name and an event emitter and returns an asynchronous iterator whose promises resolve whenever the given event is triggered. `select` would then need to return an event emitter, firing events whenever they occur on any of its elements.

We could then, say, collect these events into an array.

    collect Events.on "click", DOM.select "li > a.show.button"

Of course, that's not very useful. So let's continue on with the original example. We want the `href` property of the event target.

    map (compose (property "href"), (property "target")),
      Events.on "click", DOM.select "li > a.show.button"

With the `href`, we can now make a HTTP request. Let's assume an HTTP request returns a promise that yields a stream. We have a `read` function that (once I turn it into a multimethod) can read from a promise that will resolve into a stream.

    read http.GET href

From there, we just need to parse it.

    toJSON read http.GET href

This is just a compose operation. So now we can `map` it.

    map (compose toJSON, read, http.GET),
      map (compose (property "href"), (property "target")),
        Events.on "click", DOM.select "li > a.show.button"

We now are iterating over objects, which are the data associated with the links that were clicked. The next thing in our original example is to bind this iterator to a Web component. We'll just use a someone dubious `bind` function and pretend it knows how to do this.

    bind detailView,
      map (compose toJSON, read, http.GET),
        map (compose (property "href"), (property "target")),
          Events.on "click", DOM.select "li > a.show.button"

What we imagine this does is update the `detailView` component each time a new promise resolves. This is perhaps not as expressive as we like, but the results are encouraging. We've converted asynchronous events into an iterator and used that to drive interaction updates. We can go the other way, though, too.

    Events.on "change",
      bind detailView,
        map (compose toJSON, read, http.GET),
          map (compose (property "href"), (property "target")),
            Events.on "click", DOM.select "li > a.show.button"

This expression returns an iterator that responds to updates to the `detailView`. What we want to do here is to update the same URL that we used to get the resource. The problem is that we lost track of that URL back when we did the `GET` oepration.

Of course, we could simply assume the URL was in the data and thus we can get it from the event target. However, what if that's not the case. What if we're using an API that doesn't provide the URL to update. We _had_ the URL at one point. What we want is to keep it around somehow so that we can come back to it later.

The only way to do that within the pipeline we've set up here is to carry the URL along with the value. What we want to do is take one iterator that produces `href` values and turn it two iterators that produce `href` values. So long as we're using `map` on one of the iterators, we know the mapping between the values produced by each iterator are one-to-one.

We can imagine such a function.

    [j, k] = duplex i

The problem with this is how do incorporate it into our pipeline? We might imagine that duplex takes two functions that take iterators.

    duplex f, g, i

We can now write our pipeline like this.

    Events.on "change",
      bind detailView,
        map (([data, href]) -> data.url = href ; data),
          duplex (map (compose toJSON, read, http.GET)), identity,
            map (compose (property "href"), (property "target")),
              Events.on "click", DOM.select "li > a.show.button"

If we further define `toResource` to take a URL and optional data object, we can make this look a little nicer.

    Events.on "change",
      bind detailView,
        map (variadic toResource),
          duplex (map (compose toJSON, read, http.GET)), identity,
            map (compose (property "href"), (property "target")),
              Events.on "click", DOM.select "li > a.show.button"

For our _coup d'grace_ we can apply the changes using the resource. The only difficulty is that we need to pass two arguments to `http.PUT`, the URL, and the body. We again need our duplex function.

    each (variadic http.PUT),
      duplex (map (property "url")), (map (property "data")),
        map (compose (property "resource"), (property "target")),
          Events.on "change",
            bind detailView,
              map (variadic toResource),
                duplex (map (compose toJSON, read, http.GET)), identity,
                  map (compose (property "href"), (property "target")),
                    Events.on "click", DOM.select "li > a.show.button"

This is very nice and all, but we've got two problems. First, it's not very expressive. It's difficult to tell what the hell is going on. We have to read it inside-out. Second, we have this nesting thing happening.

Method-chaining solves both of these problems. But it's a hack. Still a hack that we can read is probably better than an elegant solution that is difficult to reason about. What we really want is to write this directly as a pipeline.

Here's what this might look like in psuedo-code.

    pipe (-> DOM.select "li > a.show.button"),
      (Events.on "click"),
      (map (compose (property "href"), (property "target"))),
      (duplex (map (compose toJSON, read, http.GET)), identity),
      (map (variadic toResource)),
      (bind detailView),
      (Events.on "change"),
      (map (compose (property "resource"), (property "target"))),
      (duplex (map (property "url")), (map (property "data"))),
      (each (variadic http.PUT))

What's weird is that _this works_. Why? Because these functions are a curryable. And `pipe` is just `compose` with the arguments reversed.

For example:

    Events.on "click"

returns a function that takes an event emitter.

Similarly:

    (map (compose (property "href"), (property "target")))

returns a function that takes an iterator and extracts the `target.href` property from the objects it produces.

At this point, the only mildly annoying thing is all the parenthesis. But we can even get rid of most of these if we want.

    variadic pipe [
      Events.on "click", DOM.select "li > a.show.button"
      map compose (property "href"), (property "target")
      duplex (map (compose toJSON, read, http.GET)), identity
      map variadic toResource
      bind detailView
      Events.on "change"
      map compose (property "resource"), (property "target")
      duplex (map (property "url")), (map (property "data"))
      each variadic http.PUT
    ]

We can do even better than this, though. First, let's go back and clean up something that's a little ambiguous. Namley, what does `bind` actually do?

What we have is a function that takes an IC component and an iterator. It binds the component to the value produced by the iterator. It needs to show (display) the component at that point. And yet it needs to return the component value, too. This function might look something like this.

    curry (component, iterator) ->
      each ((compose show, bind) component), iterator
      component

The semantics here feel wrong. This seems like something we should be able to do more naturally. Especially given that what we're doing is taking one event stream and using it to produce a second one. But this is really two separate pipelines.

    variadic pipe [
      Events.on "click", DOM.select "li > a.show.button"
      map compose (property "href"), (property "target")
      duplex (map (compose toJSON, read, http.GET)), identity
      map variadic toResource
      each ((compose show, bind) detailView)
    ]

    variadic pipe [
      Events.on "change", detailView
      map compose (property "resource"), (property "target")
      duplex (map (property "url")), (map (property "data"))
      each variadic http.PUT
    ]

The only thing slightly aggravating is that these things seem related. It feels a bit like what we want is a _new_ `detailView`, a fresh one. Or a fresh _something_. That would be more consistent with our pipeline idiom. Other than that, it's hard to see exactly why that helps.

In addition, the `each` clause at the end of our first pipeline seems weird. What if we don't want `bind` to return the component for some reason?

I've run into this same problem several times before, where I basically want to distribute an argument over several functions. Basically, what we're talking about looks like this:

    distribute = (f, g, x) ->
      f x
      g x
      x

Returning `x` is more a thing of not being sure what else to return. We could also define it like this, I suppose:

    distribute = (f, g, x) -> [ f x, g x ]

Or, more generally, like this:

    distribute = (fx, x) -> map ((f) -> f x), fx

This is very similar in spirit to the S combinator. So that seems pretty legit, right? So let's us it in our pipelines.

    variadic pipe [
      Events.on "click", DOM.select "li > a.show.button"
      map compose (property "href"), (property "target")
      duplex (map (compose toJSON, read, http.GET)), identity
      map variadic toResource
      each distribute [ bind, show ], detailView
    ]

    variadic pipe [
      Events.on "change", detailView
      map compose (property "resource"), (property "target")
      duplex (map (property "url")), (map (property "data"))
      each variadic http.PUT
    ]

Suppose we also allow `property` to take an array of property names, so we can avoid composing `property` functions.

    variadic pipe [
      Events.on "click", DOM.select "li > a.show.button"
      map property [ "href", "target" ]
      duplex (map (compose toJSON, read, http.GET)), identity
      map variadic toResource
      each distribute [ bind, show ], detailView
    ]

    variadic pipe [
      Events.on "change", detailView
      map property [ "resource", "target" ]
      duplex (map (property "url")), (map (property "data"))
      each variadic http.PUT
    ]

We can even use multimethods for this so that if you pass an iterator as the second argument to `property`, in automatically does a `map`.

    variadic pipe [
      Events.on "click", DOM.select "li > a.show.button"
      property [ "href", "target" ]
      duplex (map (compose toJSON, read, http.GET)), identity
      map variadic toResource
      each distribute [ bind, show ], detailView
    ]

    variadic pipe [
      Events.on "change", detailView
      property [ "resource", "target" ]
      duplex (property "url"), (property "data")
      each variadic http.PUT
    ]

Now, to recombine these, we can create a new `detailView` instance for each resource and then use `duplex` to get the `change` events.

    variadic pipe [
      Events.on "click", DOM.select "li > a.show.button"
      property [ "href", "target" ]
      duplex (map (compose toJSON, read, http.GET)), identity
      map variadic toResource
      map create DetailView
      duplex (each distribute [ bind, show ], detailView), identity
      map compose (Events.on "change"), second
      property [ "resource", "target" ]
      duplex (property "url"), (property "data")
      each variadic http.PUT
    ]

Let's switch the remaining `compose` operations `pipe` to make it a little easier to read.

    variadic pipe [
      Events.on "click", DOM.select "li > a.show.button"
      property [ "href", "target" ]
      duplex (map (pipe http.GET, read, toJSON)), identity
      map variadic toResource
      map create DetailView
      duplex (each distribute [ bind, show ], detailView), identity
      map pipe second, Events.on "change"
      property [ "resource", "target" ]
      duplex (property "url"), (property "data")
      each variadic http.PUT
    ]

Let's change `pipe` to it can take arrays.


    pipe [
      Events.on "click", DOM.select "li > a.show.button"
      property [ "href", "target" ]
      duplex (map (pipe http.GET, read, toJSON)), identity
      map variadic toResource
      map create DetailView
      duplex (each distribute [ bind, show ]), identity
      map pipe second, Events.on "change"
      property [ "resource", "target" ]
      duplex (property "url"), (property "data")
      each variadic http.PUT
    ]

This is much nicer. But I'd argue that it's still harder to read then the method-chaining variant. One advantage of method chaining is that each method knows it's operating on the equivalent of an iterator. Whereas in our construction, we just have a series of functions. We have to use `map`, or a similar function, to convert each function into a function that accepts an iterator. But what if…

What if we had a way to have each function automatically `map` themselves if they weren't already iterator functions? How can we identify iterator _functions_ and distinguish them from ordinary functions?

This is reminiscent of trying to come up with an `isIteratorFunction` function. If we require some kind of type tag, we lose the ability to just use ordinary functions. Or at least, we have to call a function to make sure they're tagged before using them. If we _could_ do this somehow, though, the above code simplifies even further.

    pipe [
      Events.on "click", DOM.select "li > a.show.button"
      property [ "href", "target" ]
      duplex (pipe http.GET, read, toJSON), identity
      variadic toResource
      create DetailView
      duplex (each distribute [ bind, show ]), identity
      pipe second, Events.on "change"
      property [ "resource", "target" ]
      duplex (property "url"), (property "data")
      each variadic http.PUT
    ]

That's not a big win, but we're pretty close now to what we have with chaining. If we keep going like this and assume all methods that don't take arrays are smart enough to convert arrays to arguments, we get this.

    pipe [
      Events.on "click", DOM.select "li > a.show.button"
      property [ "href", "target" ]
      duplex (pipe http.GET, read, toJSON), identity
      toResource
      create DetailView
      duplex (each distribute [ bind, show ]), identity
      pipe second, Events.on "change"
      property [ "resource", "target" ]
      duplex (property "url"), (property "data")
      each http.PUT
    ]

Changing `property` to the more active get, `duplex` to `split`, `Events.on` to simply `events`, and some more clever overloading, we can get down to this.

    flow [
      events "click", DOM.select "li > a.show.button"
      get w "target href"
      split [ http.GET, read, toJSON ], identity
      create Resource
      create DetailView
      show
      events "change"
      get w "target resource"
      split (get "url"), (get "data")
      http.PUT
    ]

We can even get rid of the `split` calls by introducing a clever composition operator that knows about iterators.

    flow [
      events "click", DOM.select "li > a.show.button"
      get w "target href"
      apply (create Resource), [ http.GET, read, toJSON ], identity
      create DetailView
      tee show
      events "change"
      get w "target resource"
      apply http.PUT, (get "url"), (get "data")
    ]

The `apply` function generally might simply work like `partial`. But this is a little more sophisticated. It's a sort of `map` composition operator. Perhaps `map-compose` would be better, but for the moment, I'll stick with `apply`.

    apply = (f, gx) -> flow [ (split gx...), f ]

This end result is so appealing—I think that, at this stage, it rivals method chaining—that it's worth it to return to the question of how we deal with functions in the flow that aren't iterator functions.

What we're really talking about is an iterator monad. We need the `wrap` function for an iterator monad. Each function that's passed in is wrapped into an iterator monad. The iterator monad is, itself, an iterator function. But how to implement `wrap`?

The tricky part here is that we don't have anyway to tell if a given function accepts as iterator as it's last argument. Take for example:

    get w "target href"

We can simply define `get` to be a multimethod that can take an iterator. Okay, so far, so good. How about `create`? Again, we can go ahead and define a version of `create` that takes an iterator.

This pattern repeats, which suggests that we just need to define our functions to accept iterators in the first place, by wrapping them beforehand.

Here's a wrapper function to do this for an arbitrary function:

    iterator = (f) ->
      (ax..., x) -> if isIterator x then map (f ax...), x else f ax..., x

To use it we simply write:

    get = binary iterator curry (px, y) -> fold y, ((p) -> y[p]), px

Or:

    create = binary iterator curry (k, ax...) -> new k ax...

In other words, it looks like any other of a number of second-order functions, like `curry` or `binary`. Any function that we suspect might be useful as an iterator monad we just wrap it accordingly. And all such functions can be then used with an iterator. This should work except in cases where the function already takes an iterator. However, in those cases, there's no need to use the `iterator` adapter.

Let's try a different example. Instead of an even trigger, we're going to simply pass in a URL and return a reactive data object that will synchronize with the corresponding resource.

    synchronize = (url, increment = 6e4) ->

      data = create EventedData

      flow [
        events "change", data
        get w "target"
        http.PUT url
      ]

      flow [
        repeat timer increment, -> http.GET url
        read
        toJSON
        update data
      ]

      data

The bit about the timer is a little dodgy. I don't think timers currently return the results of their timer function. Should they? And it feels like these two flows should be connected somehow. Also, we should probably be using HTTP push here, but I don't recall at the moment what the interface is for using it. Finally, doesn't this create a feedback loop? The timer (or push) updates the evented data object which would trigger the change event. Which would then trigger a PUT. If we're using HTTP push, that would then trigger another update.
