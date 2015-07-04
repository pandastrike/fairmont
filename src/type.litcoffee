# Type Functions

    {curry, deepEqual} = require "./core"

    {describe, assert} = require "./helpers"

    describe "Type functions", (context) ->

## deepEqual

This is actually defined in `core` to avoid circular dependences. However, we require and export it here, since this is where it logically belongs.

## type

Get the type of a value. Possible values are: `number`, `string`, '`boolean`, `date`, `regexp`, `function`, `array`, `object`, `null`, `undefined`.

      type = (x) -> Object::toString.call(x).slice(8, -1).toLowerCase()

      context.test "type"

## isType

      isType = curry (t, x) -> type(x) == t

      context.test "isType"

## instanceOf

      instanceOf = curry (t, x) -> x instanceof t

      context.test "instanceOf"

## isNumber

      isNumber = (n) -> n == +n

      context.test "isNumber", ->
        assert isNumber 7
        assert ! isNumber "7"
        assert ! isNumber false


## isInteger

Adapted from [StackOverflow][isInteger].

[isInteger]:http://stackoverflow.com/questions/3885817/how-to-check-if-a-number-is-float-or-integer/3885844#3885844

      isInteger = (n) -> n == +n && n == (n|0)

      context.test "isInteger", ->
        assert isInteger 5
        assert ! isInteger 3.5
        assert ! isInteger "5"
        assert ! isInteger NaN

## isFloat

      isFloat = (n) -> n == +n && n != (n|0)

      context.test "isFloat", ->
        assert isFloat 3.5
        assert ! isFloat 5
        assert ! isFloat "3.5"
        assert ! isFloat NaN

## isBoolean

      isBoolean = isType "boolean"

      context.test "isBoolean", ->
        assert isBoolean true
        assert !isBoolean 7

## isDate

      isDate = isType "date"

      context.test "isDate", ->
        assert isDate (new Date)
        assert !isDate 7

## isRegexp

      isRegexp = isType "regexp"

      context.test "isRegexp", ->
        assert isRegexp /\s/
        assert !isRegexp 7

## isString

      isString = isType "string"

      context.test "isString", ->
        assert isString "x"
        assert !isString 7

## isFunction

      isFunction = isType "function"

      context.test "isFunction", ->
        assert isFunction ->
        assert !isFunction 7

## isGenerator

      isGenerator = (x) ->
        x.constructor.name == "GeneratorFunction"

      context.test "isGenerator", ->
        f = -> yield true
        assert isGenerator f

## isObject

      isObject = isType "object"

      context.test "isObject", ->
        assert isObject {}
        assert !isObject 7

## isArray

      isArray = isType "array"

      context.test "isArray", ->
        assert isArray []
        assert !isArray 7

## isValue

      isValue = (x) -> x?

      context.test "isValue", ->
        assert isValue {}
        assert !isValue undefined

---

      module.exports = {deepEqual, type, isType, instanceOf,
        isBoolean, isNumber, isString, isFunction, isGenerator,
        isObject, isArray, isValue}
