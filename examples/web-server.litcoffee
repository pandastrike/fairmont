# Example: Reactive Web Server

This is a trivial Web server implemented in a reactive style. This example builds on what the [echo server example](./echo-server.litcoffee). The middleware style of processing requests popularized by Rack and Express is a natural result of using functional reactive programming with an HTTP server. Except that none of the functions need to worry about a `next` function. 

We create the server like we would normally do, except we don't pass in a callback. Instead, we're going to use it to generate request/response pairs.

    http = require "http"

    server = http.createServer().listen(1337)

We'll define a very silly logger, for demonstration purposes.

    logger = (request, response) ->
      console.log request.method, request.url, response.statusCode

Let's pick up a few building blocks from Fairmont.

    {start, flow, events, select, variadic,
      tee, map, iterator, curry} = require "../src"

Most of these are pretty self-explanatory, but some people won't have seen the term [variadic](https://github.com/pandastrike/fairmont/blob/master/src/core.litcoffee#variadic) before.
`variadic` takes a function which receives a list of arguments, and returns a new function which takes those same arguments as an array.
This makes it easier to pipeline and compose functions, because it makes it easier to pass their arguments from function to function.

Next, we kick off the flow.

    start flow [

We pick up request events from the server.

      events "request", server

We're only interested here in `GET` requests. In real life, you might use a request classifier here.

      select variadic (request) -> request.method == "GET"

We're going to further narrow our interest to only the root resource. Again, in real life, we might do, say, authentication here.

      select variadic (request) -> request.url == "/"

We'll respond with `hello, world`. The `tee` function returns an iterator function that operates on the value produced by the iterator, but then produces the original value. (In contrast to `map`, which produces the result of applying the function.) This allows us to do something with the request, but also pass it along to the next iterator function.

      tee variadic (_, response) ->
        response.statusCode = 200
        response.write "hello, world"
        response.end()

Now that we're done, we'll log the result.

      map variadic logger

And that's the whole flow.

    ]
