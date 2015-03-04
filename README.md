# Fairmont

A collection of useful CoffeeScript/JavaScript functions. These include functions to help with functional programming, arrays, objects, and more. Fairmont is inspired by [Underscore][100], [EssentialJS][110], and [prelude.coffee][120].

[100]:http://underscorejs.org/
[110]:https://github.com/elclanrs/essential.js
[120]:http://xixixao.github.io/prelude-ls/

## Why Fairmont?

Fairmont offers a combination of features we couldn't find in existing libraries:

* Functional programming friendly
* ES6 aware (in particular, uses promises and generators for async operations)
* Comprehensive

Fairmont is also a literate programming project—the documentation, code, examples, and tests are together, making it easy to see what a function does, how it does it, and why it does it that particular way.

### Functional Programming Friendly

Fairmont is built on a functional programming foundation, including implementations for currying, partial application, and composition. Most functions are curried by default and designed with composition in mind.

### ES6 Aware

Fairmont wraps common asynchronous operations so they can be used in `yield` expressions. For example, here's how you can read a file using Fairmont.

```coffee
content = yield read "war-and-peace.txt"
```

### Comprehensive

One of the nice things about Underscore is that it offers a lot of useful functions. Many common tasks can be written entirely using Underscore functions. Fairmont has a similar ambition. While there's nothing wrong with specialized libraries, there are times when you just want a good Swiss Army Knife.

## List of Functions

### Core Functions

* [API Reference][core]


    identity, wrap, curry, _, partial, flip,
    compose, pipe, variadic, unary, binary, ternary

[core]:src/core.litcoffee

### Logical Functions

* [API Reference][logical]


    f_and, f_or, f_not, f_eq, f_neq

[logical]:src/logical.litcoffee

### Numeric Functions

* [API Reference][numeric]


    gt, lt, gte, lte, add, sub, mul, div, mod,
    even, odd, min, max

[numeric]:src/numeric.litcoffee

### Type Functions

* [API Reference][core]


    deep_equal, type, is_type, instance_of

[type]:src/type.litcoffee

### Array functions

* [API Reference][array]


    fold, foldr, map, filter, any, all, each, cat, slice,
    first, last, rest, take, leave, drop, includes, unique_by,
    unique, uniq, flatten, dupes, union, intersection, remove, shuffle

[array]:src/array.litcoffee

### Crypto Functions

* [API Reference][crypto]


    md5, base64, base64url

[crypto]:src/crypto.litcoffee

### File System Functions

* [API Reference][fs]


    exists, stat, read, readdir, write, chdir, rm, rmdir

[fs]:src/fs.litcoffee

### Object Functions

* [API Reference][object]


    include/extend, merge, clone, pluck, property, delegate, bind, detach

[object]:src/object.litcoffee

### String Functions

* [API Reference][string]


    capitalize, title_case, camel_case, underscored,
    dashed, plain_text, html_escape, w

[string]:src/string.litcoffee

### Miscellaneous Functions

* [API Reference][misc]


    shell, sleep, timer, memoize, abort

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
