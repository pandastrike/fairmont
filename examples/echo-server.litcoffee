# Example: Reactive Echo Server

This is a trivial example of a reactive style of programming. It's a simple echo server. It would be much easier to just write this as a one-liner where we pipe the connection back to itself. However, it's the simplicity of the example that makes it good for demonstrating reactive programming.

We create the server just like we usually would, except we don't set up a callback for connections. We're going to listen for `connection` events instead.

    net = require "net"
    server = net.createServer().listen(1337)

The `flow` function takes an array of functions and returns an iterator. Basically, it's like `pipe`, which works like the `compose`, but with the arguments reversed. This allows us to place the operations in the sequence they'll actually occur. In addition, `flow`, knowing that the end result is intended to be used as an iterator function, creates an iterator function from the result of the composition.

Let's grab the necessary building blocks from Fairmont.

    {start, flow, events, map, stream, pump} = require "../src/index"

As with any iterator, you must ultimately pass it to a function that uses it. The purpose of most such functions, such as `collect` or `reduce`, is to return a value based on the iteration. However, the purpose of some iterators is simply to start an event or processing loop, as is typically the case with `flow`. The `start` function allows you to kick of such a loop.

The first expression in a flow should evaluate to an iterator. Subsequent expressions must evaluate to functions that _take_ an iterator. However, the first expression effectively bootstraps the flow.

Here's a simple function that uses a flow to take a stream and echo it back to itself. The `stream` function takes a stream and returns an iterator that produces values from the stream. Then we write these back to the connection with `pump`. The `pump` function, given a stream and an iterator, writes the values produced by the iterator to the stream. The `pump` function is curried here, so that it can take the iterator produced by `stream`.

    echo = (s) ->
      start flow [
        stream s
        pump s
      ]

Again, it would have been simpler to just write `s.pipe(s)`, but the point here is to illustrate how a flow works.

Here's another simple function that takes a server that emits connection events and returns an iterator that produces connections. We're curry `events` here, so that the resulting function need only take a connection to produce an iterator. Also, the `events` function can take an event map, which allows the iterator to return `done` as `true` when it gets a `close` event.

    connections = events name: "connection", end: "close", error: "error"

We're ready to start our main flow.

    start flow [

We're going to use our `connections` function to take connection events and convert them into an iterator that produces connections.

      connections server

The `map` function returns an iterator, but here we're simplying currying it—notice we don't pass an iterator, just a function. This evalutes to a function that will take an iterator and produce another iterator. Remember, the `echo` function we're using here contains a nested flow.

      map echo

In this simple example, that's the end of the flow. There's not much to it. We get a connections and stream them back into themselves. However, we could have replaced the echo flow with something that processes the input and does something more interesting.

    ]
