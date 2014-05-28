# Fairmont

A collection of useful CoffeeScript/JavaScript functions.
#
## Array Functions ##
#
### remove ###
#
Destructively remove an element from an array. Returns the element removed.
#
```coffee-script
a = w "foo bar baz"
remove( a, "bar" )
```
### uniq ###
#
Takes an array and returns a new array with all duplicate values from the original array removed. Also takes an optional hash function that defaults to calling `toString` on the elements.
#
```coffee-script
uniq [1,2,3,1,2,3,4,5,6,3,6,2,4]
# returns [1,2,3,4,5,6]
```
### shuffle ###
#
Takes an array and returns a new array with all values shuffled randomly.
```coffee-script
shuffle ["a", "b", "c", "d", "e", "f"]
# for e.g.: returns ["b", "c", "d", "e", "f", "a"]
```
#
Use the [Fisher-Yates algorithm][shuffle-1].
#
Adapted from the [CoffeeScript Cookbook][shuffle-2].
#
[shuffle-1]:http://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle
[shuffle-2]:http://coffeescriptcookbook.com/chapters/arrays/shuffling-array-elements
#
## Hashing/Encoding Functions
#
#
### md5 ###
#
Return the MD5 hash of a string.
#
```coffee-script
nutshell = md5( myLifeStory )
```
#
### base64 ###
#
Base64 encode a string. (Not URL safe.)
#
```coffee-script
image = data: base64( imageData )
```
#
## File System Functions
#
All file-system functions are based on Node's `fs` API. This is not `require`d unless the function is actually invoked.
#
### exists ###
#
Check to see if a file exists.
#
```coffee-script
source = read( sourcePath ) if exists( sourcePath )
```
#
### read ###
#
Read a file synchronously and return a UTF-8 string of the contents.
#
```coffee-script
source = read( sourcePath ) if exists( sourcePath )
```
#
### readdir ###
#
Synchronously get the contents of a directory as an array.
#
```coffee-script
for file in readdir("documents")
  console.log read( file ) if stat( file ).isFile()
```
#
### stat ###
#
Synchronously get the stat object for a file.
#
```coffee-script
for file in readdir("documents")
  console.log read( file ) if stat( file ).isFile()
```
#
### write ###
#
Synchronously write a UTF-8 string to a file.
#
```coffee-script
write( file.replace( /foo/g, 'bar' ) )
```
#
### chdir ###
#
Change directories, execute a function, and then restore the original working directory.
#
```coffee-script
chdir "documents", ->
  console.log read( "README" )
```
#
### rm ###
#
Removes a file.
#
```coffee-script
rm "documents/reamde.txt"
```
#
### rmdir ###
#
Removes a directory.
#
```coffee-script
rmdir "documents"
```
#
## General Purpose Functions ##
#
### w ###
#
Split a string on whitespace. Useful for concisely creating arrays of strings.
#
```coffee-script
console.log word for word in w "foo bar baz"
```
### to ###
#
Hoist a value to a given type if it isn't already. Useful when you want to wrap a value without having to check to see if it's already wrapped.
#
For example, to hoist an error message into an error, you would use:
#
```coffee-script
to(error, Error)
```
### abort ###
#
Simple wrapper around `process.exit(-1)`.
### memoize ###
#
A very simple way to cache results of functions that take a single argument. Also takes an optional hash function that defaults to calling `toString` on the function's argument.
#
```coffee-script
nickname = (email) ->
  expensiveLookupToGetNickname( email )
#
memoize( nickname )
```
### timer ###
#
Set a timer. Takes an interval in microseconds and an action. Returns a function to cancel the timer. Basically, a more convenient way to call `setTimeout` and `clearTimeout`.
#
```coffee-script
cancel = timer 1000, -> console.log "Done"
cancel()
```
#
## Object Functions
#
#
### include ###
#
Adds the properties of one or more objects to another.
#
```coffee-script
include( @, ScrollbarMixin, SidebarMixin )
```
#
### property ###
#
Add a `property` method to a class, making it easier to define getters and setters on its prototype.
#
```coffee-script
class Foo
  include @, Property
  property "foo", get: -> @_foo, set: (v) -> @_foo = v
```
#
Properties defined using `property` are enumerable.
#
### delegate ###
#
Delegates from one object to another by creating functions in the first object that call the second.
#
```coffee-script
delegate( aProxy, aServer )
```
#
### merge ###
#
Creates new object by progressively adding the properties of each given object.
#
```coffee-script
options = merge( defaults, globalOptions, localOptions )
```
#
### clone ###
#
Perform a deep clone on an object. Taken from [The CoffeeScript Cookboox][clone-1].
#
[clone-1]:http://coffeescriptcookbook.com/chapters/classes_and_objects/cloning
#
```coffee-script
copy = clone original
```
#
## String Functions ##
#
#
### capitalize ###
#
Capitalize the first letter of a string.
#
### titleCase ###
#
Capitalize the first letter of each word in a string.
#
### camelCase ###
#
Convert a sequence of words into a camel-cased string.
#
```coffee-script
# yields fooBarBaz
camel_case "foo bar baz"
Adapted from Mustache.js
#
## Type Functions ##
#
## type ##
#
Get the type of a value. Possible values are: `number`, `string`, '`boolean`, `data`, `regexp`, `function`, `array`, `object`, `null`, `undefined`. Adapted from [The CoffeeScript Cookbook][type-0] and based on Douglas Crockford's [remedial JavaScript blog post][type-1].
[type-0]:http://coffeescriptcookbook.com/chapters/classes_and_objects/type-function
[type-1]:http://javascript.crockford.com/remedial.html
#
```coffee-script
foo() if type( foo ) == "function"
```
