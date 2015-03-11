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

## List of Functions

### Core Functions

* [API Reference][core]

>

    identity, wrap, curry, _, partial, flip,
    compose, pipe, variadic, unary, binary, ternary

[core]:src/core.litcoffee

### Logical Functions

* [API Reference][logical]

>

    f_and, f_or, negate, f_eq, f_neq

[logical]:src/logical.litcoffee

### Numeric Functions

* [API Reference][numeric]

>

    gt, lt, gte, lte, add, sub, mul, div, mod,
    even, odd, min, max

[numeric]:src/numeric.litcoffee

### Type Functions

* [API Reference][core]

>

    deep_equal, type, is_type, instance_of,
      is_string, is_function

[type]:src/type.litcoffee

### Array functions

* [API Reference][array]

>

    cat, slice, first, second, third, last, rest,
      includes, unique_by, unique, uniq, dupes, union, intersection,
      remove, shuffle

[array]:src/array.litcoffee

### Iterator Functions

* [API Reference][it]

>

    is_iterable, iterator, is_iterator, iterate,
      collect, map, fold, foldr, select, reject, any, all, zip, unzip,
      assoc, project, flatten, partition, take, leave, skip, sample

[it]:src/iterator.litcoffee

### Crypto Functions

* [API Reference][crypto]

>

    md5, base64, base64url

[crypto]:src/crypto.litcoffee

### File System Functions

* [API Reference][fs]

>

    exists, stat, read, readdir, read_stream, read_block, lines,
    write, chdir, rm, rmdir

[fs]:src/fs.litcoffee

### Object Functions

* [API Reference][object]

>

    include/extend, merge, clone, pluck, property, delegate, bind, detach

[object]:src/object.litcoffee

### String Functions

* [API Reference][string]

>

    capitalize, title_case, camel_case, underscored,
    dashed, plain_text, html_escape, w

[string]:src/string.litcoffee

### Miscellaneous Functions

* [API Reference][misc]

>

    times, shell, sleep, timer, memoize, abort

[misc]:src/index.litcoffee

## Status

Fairmont is still under heavy development and is `alpha` quality, meaning you should probably not use it in your production code.

## Roadmap

You can get an idea of what we're planning by looking at the [issues list][200]. If you want something that isn't there, and you think it would be a good addition, please open a ticket.

[200]:https://github.com/pandastrike/fairmont/issues

Our overarching goals for the project include:

* Making the library more comprehensive

* Improving the tests and documentation

* Ensuring that we can use an FP style in real-world scenarios

* Introducing an idiom for supporting lazy evaluation
