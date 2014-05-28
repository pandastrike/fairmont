## Array Functions ##
### remove ###

Destructively remove an element from an array. Returns the element removed.

```coffee-script
a = w "foo bar baz"
remove( a, "bar" )
```
### uniq ###

Takes an array and returns a new array with all duplicate values from the original array removed. Also takes an optional hash function that defaults to calling `toString` on the elements.

```coffee-script
uniq [1,2,3,1,2,3,4,5,6,3,6,2,4]
# returns [1,2,3,4,5,6]
```
### shuffle ###

Takes an array and returns a new array with all values shuffled randomly.
```coffee-script
shuffle ["a", "b", "c", "d", "e", "f"]
# for e.g.: returns ["b", "c", "d", "e", "f", "a"]
```

Use the [Fisher-Yates algorithm][shuffle-1].

Adapted from the [CoffeeScript Cookbook][shuffle-2].

[shuffle-1]:http://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle
[shuffle-2]:http://coffeescriptcookbook.com/chapters/arrays/shuffling-array-elements












## General Purpose Functions ##
## w ###
Mixins
Direct requires
$.type = require "./src/type"
$.assert = require "./src/assert"

Direct definitions
Very simplistic memoize - only works for one argument
where toString is a unique value



Convenient way to define properties

class Foo

include @, Property

property foo: get: -> "foo"

Shallow merge



Adapted from Mustache.js



type - reliable, consistent type function. Adapted from:
http://coffeescriptcookbook.com/chapters/classes_and_objects/type-function
See also, of course: http://javascript.crockford.com/remedial.html



