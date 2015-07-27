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
* seamless integration between synchronous and asynchronous operations
* … and more!

## Components

This is the main library for Fairmont.
It includes/requires several others:

* [`fairmont-core`](https://github.com/pandastrike/fairmont-core) - [support functions for currying, partial application, function composition, and helper functions](https://github.com/pandastrike/fairmont-core/blob/master/src/index.litcoffee)
* [`fairmont-reactive`](https://github.com/pandastrike/fairmont-reactive) - [Reducer functions](https://github.com/pandastrike/fairmont-reactive/blob/master/src/reducer.litcoffee), [iterator functions](https://github.com/pandastrike/fairmont-reactive/blob/master/src/iterator.litcoffee), and [functional reactive programming](https://github.com/pandastrike/fairmont-reactive/blob/master/src/reactive.litcoffee)
* [`fairmont-multimethods`](https://github.com/pandastrike/fairmont-multimethods/) - [CLOS-style multimethods in CoffeeScript](https://github.com/pandastrike/fairmont-multimethods/blob/master/src/index.litcoffee) (more detail on our [blog](https://www.pandastrike.com/posts/20150616-multimethods))
* [`fairmont-filesystem`](https://github.com/pandastrike/fairmont-filesystem/) - [filesystem functions](https://github.com/pandastrike/fairmont-filesystem/blob/master/src/index.litcoffee)
* [`fairmont-process`](https://github.com/pandastrike/fairmont-process/) - [functions for Unix processes](https://github.com/pandastrike/fairmont-process/blob/master/src/index.litcoffee)
* [`fairmont-crypto`](https://github.com/pandastrike/fairmont-crypto/) - [basic cryptographic functions](https://github.com/pandastrike/fairmont-crypto/blob/master/src/index.litcoffee)
* [`fairmont-helpers`](https://github.com/pandastrike/fairmont-helpers/) - a range of functions which make it easier to work with arrays, strings, types, and other fundamental building blocks

## Examples

You can get a feel for what Fairmont can do for you by [checking out the examples](https://github.com/pandastrike/fairmont-reactive/tree/master/examples).

## Reference

Fairmont uses [literate programming](http://www.coffeescriptlove.com/2013/02/literate-coffeescript.html), so each source file doubles as documentation. Please see the [source directory](./src/index.litcoffee) for more.

## Status

Fairmont is still under heavy development and is `beta` quality, meaning you should probably not use it in your production code.

## Roadmap

You can get an idea of what we're planning by looking at the [issues list][200]. If you want something that isn't there, and you think it would be a good addition, please open a ticket.

[200]:https://github.com/pandastrike/fairmont/issues

