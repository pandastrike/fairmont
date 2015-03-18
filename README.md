# Fairmont

A collection of useful JavaScript functions to support a functional style of programming that takes advantage of ES6 features like iterators, generators, and promises. Fairmont is inspired by [Underscore][100], [EssentialJS][110], and [prelude.coffee][120].

[100]:http://underscorejs.org/
[110]:https://github.com/elclanrs/essential.js
[120]:http://xixixao.github.io/prelude-ls/

## Why Fairmont?

Fairmont offers a combination of features we couldn't find in existing libraries. In particular, we wanted:

* To use a functional programming style, even when performing asynchronous operations&hellip;

* While coming as close to inline code for performance as possible (read: use lazy evaluation when working with collections)&hellip;

* Taking full-advantage of ES6 features like iterators, generators, and promises, which offer powerful new ways of doing things

For example, here's how we would define a function that takes a path and returns a content-addressable dictionary of the files it contains.

```coffee
content_map = async (path) ->
  paths = collect map (compose resolve, join path), yield readdir path
  assoc zip (map (compose md5, read), paths), paths
```

We've seamlessly integrated asynchronous functions with synchronous functions, even when doing composition. Behind the scenes we're using iterators to avoid multiple passes across the data. We make two passes here, even though it appears that we're making five.

Fairmont is also a literate programming project—the documentation, code, examples, and tests are together, making it easy to see what a function does, how it does it, and why it does it that particular way.

## Function Reference

* [Core][core]
* [Logical][logical]
* [Numeric][numeric]
* [Type][core]
* [Array][array]
* [Iterator][it]
* [Crypto-Related][crypto]
* [File System][fs]
* [Object][object]
* [String][string]
* [Other][misc]


[core]:src/core.litcoffee
[logical]:src/logical.litcoffee
[numeric]:src/numeric.litcoffee
[type]:src/type.litcoffee
[array]:src/array.litcoffee
[it]:src/iterator.litcoffee
[crypto]:src/crypto.litcoffee
[fs]:src/fs.litcoffee
[object]:src/object.litcoffee
[string]:src/string.litcoffee
[misc]:src/index.litcoffee

## Status

Fairmont is still under heavy development and is `alpha` quality, meaning you should probably not use it in your production code.

## Roadmap

You can get an idea of what we're planning by looking at the [issues list][200]. If you want something that isn't there, and you think it would be a good addition, please open a ticket.

[200]:https://github.com/pandastrike/fairmont/issues
