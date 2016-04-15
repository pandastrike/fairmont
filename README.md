# Fairmont

Fairmont is a family of JavaScript libraries for functional reactive programming.
Fairmont takes full advantage of ES6+ features like iterators (including async iterators), generators, and promises.
Inspired by libraries like [Underscore](http://underscorejs.org/) and many others, Fairmont features include:

* reactive programming support through async iterators
* lazy evaluation on collection operations via iterators
* core functional operations, like currying and composition
* bridge functions for integrating with OOP-based libraries
* common file and stream based operations
* streams and event emitters modeled as asynchronous iterators
* observers for reacting to changes in state
* unifies synchronous and asynchronous programming models

## Examples

Here's a simple reactive Web app implementing a counter using Fairmont's Reactive programming functions.

In JavaScript:

```javascript
var $ = require("jquery"),
  F = require("fairmont");

$(function() {

  var data = { counter: 0 };

  F.go([
    F.events("click", $("a[href='#increment']")),
    F.map(function() { data.counter++; })
  ]);

  F.go([
    F.events("change", F.observe(data)),
    F.map(function() {
      $("p.counter")
        .html(data.counter);
    })
  ]);
});

```

In CoffeeScript:

```coffeescript
{start, flow, events, map, observe} = require "fairmont-reactive"

$ = require "jquery"

$ ->

  data = counter: 0

  go [
    events "click", $("a[href='#increment']")
    map -> data.counter++
  ]

  go [
    events "change", observe data
    map ->
      $("p.counter")
      .html data.counter
  ]
```

You can run [this example][] or look at our other reactive examples:

- a [todo-list][]
- an [echo server][]
- a [Web server][]
- a [file watcher][]

[this example]:https://github.com/pandastrike/fairmont-reactive/blob/master/examples/web-apps/counter
[todo-list]:https://github.com/pandastrike/fairmont-reactive/blob/master/examples/web-apps/todo-list
[echo server]:https://github.com/pandastrike/fairmont-reactive/blob/master/examples/echo-server.litcoffee
[Web server]:https://github.com/pandastrike/fairmont-reactive/blob/master/examples/web-server.litcoffee
[file watcher]:https://github.com/pandastrike/fairmont-reactive/blob/master/examples/file-watcher.litcoffee

## Installation

You can simply install Fairmont as a whole:

`npm install fairmont`

Or you can simply install the components you need.

Example:

`npm install fairmont-core`

Learn more about the individual Fairmont components by clicking on the links below:

- [fairmont-core][]
- [fairmont-reactive][]
- [fairmont-multimethods][]
- [fairmont-helpers][]
- [fairmont-crypto][]
- [fairmont-process][]
- [fairmont-filesystem][]

The [API Reference] provides documentation on each component and its corresponding functions.

## Status

Fairmont is available for production use.
We use Fairmont is wide-variety of development projects.
We welcome contributors!

## Roadmap

You can get an idea of what we're planning by looking at the [tickets][]. If you want something that isn't there, and you think it would be a good addition, please open a ticket.

[tickets]:https://github.com/pandastrike/fairmont/issues
[fairmont]:https://github.com/pandastrike/fairmont
[fairmont-core]:https://github.com/pandastrike/fairmont-core
[fairmont-reactive]:https://github.com/pandastrike/fairmont-reactive
[fairmont-multimethods]:https://github.com/pandastrike/fairmont-multimethods
[fairmont-helpers]:https://github.com/pandastrike/fairmont-helpers
[fairmont-crypto]:https://github.com/pandastrike/fairmont-crypto
[fairmont-process]:https://github.com/pandastrike/fairmont-process
[fairmont-filesystem]:https://github.com/pandastrike/fairmont-filesystem
[API Reference]:https://github.com/pandastrike/fairmont/wiki/API-Reference
