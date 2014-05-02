# Fairmont

A collection of useful CoffeeScript/JavaScript functions.

## General Purpose Functions

**w** Split a string on whitespace. Useful for concisely creating arrays of strings.

    console.log word for word in w "foo bar baz"
    
**type** Get the type of a value. Possible values are: `number`, `string`, '`boolean`, `data`, `regexp`, `function`, `array`, `object`, `null`, `undefined`. Adapted from [The CoffeeScript Cookbook][0] and based on Douglas Crockford's [remedial JavaScript blog post][1].

[0]:http://coffeescriptcookbook.com/chapters/classes_and_objects/type-function
[1]:http://javascript.crockford.com/remedial.html

    foo() if type( foo ) == "function"

**timer** Set a timer. Takes an interval in microseconds and an action. Returns a function to cancel the timer. Basically, a more convenient way to call `setTimeout` and `clearTimeout`.

    cancel = timer 1000, -> console.log "Done"
    cancel()
    
## Array Functions

**remove** Destructively remove an element from an array. Returns the element removed.

    a = w "foo bar baz"
    remove( a, "bar" )

**uniq** Takes an array and returns a new array with all duplicate values from the original array removed. Also takes an optional hash function that defaults to calling `toString` on the elements. 

    uniq [1,2,3,1,2,3,4,5,6,3,6,2,4]
    # returns [1,2,3,4,5,6]

**shuffle** Takes an array and returns a new array with all values shuffled randomly.

    shuffle ["a", "b", "c", "d", "e", "f"]
    # for e.g.: returns ["b", "c", "d", "e", "f", "a"]

## File System Functions

All file-system functions are based on Node's `fs` API. This is not `require`d unless the function is actually invoked.

**exists** Check to see if a file exists.

    source = read( sourcePath ) if exists( sourcePath )

**read** Read a file synchronously and return a UTF-8 string of the contents.

    source = read( sourcePath ) if exists( sourcePath )

**write** Synchronously write a UTF-8 string to a file.

    write( file.replace( /foo/g, 'bar' ) )

**readdir** Synchronously get the contents of a directory as an array.

    for file in readdir("documents")
      console.log read( file ) if stat( file ).isFile()

**stat** Synchronously get the stat object for a file.

    for file in readdir("documents")
      console.log read( file ) if stat( file ).isFile()

**chdir** Change directories, execute a function, and then restore the original working directory.

    chdir "documents", ->
      console.log read( "README" )
      
**rm** Removes a file.

    rm "documents/reamde.txt"

**rmdir** Removes a directory.

    rmdir "documents"

## Hashing/Encoding Functions

**md5** Return the MD5 hash of a string.

    nutshell = md5( myLifeStory )

**base64** Base64 encode a string. (Not URL safe.)

    image = data: base64( imageData )

## Object Functions

**include** Adds the properties of one or more objects to another.

    include( @, ScrollbarMixin, SidebarMixin )

**merge** Creates new object by progressively adding the properties of each given object.

    options = merge( defaults, globalOptions, localOptions )

**delegate** Delegates from one object to another by creating functions in the first object that call the second.

    delegate( aProxy, aServer )

## Object Mixins

Mixins are objects that you can `include` into another, typically adding features to an object in the process.

**Property** Add a `property` method to a class, making it easier to define getters and setters on its prototype.

    class Foo
      include @, Property
      property "foo", get: -> @_foo, set: (v) -> @_foo = v

Properties defined using `property` are enumerable.

## Function Functions

**memoize** A very simple way to cache results of functions that take a single argument. Also takes an optional hash function that defaults to calling `toString` on the function's argument.

    nickname = (email) ->
      expensiveLookupToGetNickname( email )
      
    memoize( nickname )