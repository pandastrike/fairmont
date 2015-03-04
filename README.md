# Fairmont

A collection of useful CoffeeScript/JavaScript functions. These include functions to help with functional programming, arrays, objects, and more. It's intended as an alternative to Underscore.

## Core Functions

* [API Reference][core]


    identity, wrap, curry, _, partial, flip,
    compose, pipe, variadic, unary, binary, ternary

[core]:src/core.litcoffee

## Logical Functions

* [API Reference][logical]


    f_and, f_or, f_not, f_eq, f_neq

[logical]:src/logical.litcoffee

## Numeric Functions

* [API Reference][numeric]


    gt, lt, gte, lte, add, sub, mul, div, mod,
    even, odd, min, max

[numeric]:src/numeric.litcoffee

## Type Functions

* [API Reference][core]


    deep_equal, type, is_type, instance_of

[type]:src/type.litcoffee

## Array functions

* [API Reference][array]


    fold, foldr, map, filter, any, all, each, cat, slice,
    first, last, rest, take, leave, drop, includes, unique_by,
    unique, uniq, flatten, dupes, union, intersection, remove, shuffle

[array]:src/array.litcoffee

## Crypto Functions

* [API Reference][crypto]


    md5, base64, base64url

[crypto]:src/crypto.litcoffee

## File System Functions

* [API Reference][fs]


    exists, stat, read, readdir, write, chdir, rm, rmdir

[fs]:src/fs.litcoffee

## Object Functions

* [API Reference][object]


    include/extend, merge, clone, pluck, property, delegate, bind, detach

[object]:src/object.litcoffee

## String Functions

* [API Reference][string]


    capitalize, title_case, camel_case, underscored,
    dashed, plain_text, html_escape, w

[string]:src/string.litcoffee

## Miscellaneous Functions

* [API Reference][misc]


    shell, sleep, timer, memoize, abort

[misc]:src/index.litcoffee
