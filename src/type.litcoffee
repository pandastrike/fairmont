# Type Functions

    {curry, deepEqual} = require "./core"

    {describe, assert} = require "./helpers"

    describe "Type functions", (context) ->

## deepEqual

This is actually defined in `core` to avoid circular dependences. However, we require and export it here, since this is where it logically belongs.

## type

Get the type of a value. Possible values are: `number`, `string`, '`boolean`, `date`, `regexp`, `function`, `array`, `object`, `null`, `undefined`.

      type = (x) -> x?.constructor

      context.test "type"

## isType

      isType = curry (t, x) -> type(x) == t

      context.test "isType"

## instanceOf

      instanceOf = curry (t, x) -> x instanceof t

      context.test "instanceOf"

## isNumber

      isNumber = isType Number

      context.test "isNumber", ->
        assert isNumber 7
        assert ! isNumber "7"
        assert ! isNumber false

## isNaN

      isNaN = (n) -> Number.isNaN n

## isFinite

      isFinite = (n) -> Number.isFinite n

## isInteger

      isInteger = (n) -> Number.isInteger n

      context.test "isInteger", ->
        assert isInteger 5
        assert ! isInteger 3.5
        assert ! isInteger "5"
        assert ! isInteger NaN


## isFloat

Adapted from [StackOverflow][isFloat].

[isFloat]:http://stackoverflow.com/questions/3885817/how-to-check-if-a-number-is-float-or-integer/3885844#3885844

      isFloat = (n) -> n == +n && n != (n|0)

      context.test "isFloat", ->
        assert isFloat 3.5
        assert ! isFloat 5
        assert ! isFloat "3.5"
        assert ! isFloat NaN

## isBoolean

      isBoolean = isType Boolean

      context.test "isBoolean", ->
        assert isBoolean true
        assert !isBoolean 7

## isDate

      isDate = isType Date

      context.test "isDate", ->
        assert isDate (new Date)
        assert !isDate 7

## isRegexp

      isRegexp = isType RegExp

      context.test "isRegexp", ->
        assert isRegexp /\s/
        assert !isRegexp 7

## isString

      isString = isType String

      context.test "isString", ->
        assert isString "x"
        assert !isString 7

## isFunction

      isFunction = isType Function

      context.test "isFunction", ->
        assert isFunction ->
        assert !isFunction 7

## isObject

      isObject = isType Object

      context.test "isObject", ->
        assert isObject {}
        assert !isObject 7

## isArray

      isArray = isType Array

      context.test "isArray", ->
        assert isArray []
        assert !isArray 7

## isDefined

      isDefined = (x) -> x?

      context.test "isDefined", ->
        assert isDefined {}
        assert !isDefined undefined

## isGenerator

      GeneratorFunction = (-> yield null).constructor

      isGenerator = isType GeneratorFunction

      context.test "isGenerator", ->
        f = -> yield true
        assert isGenerator f

## isPromise

      isPromise = (x) -> x?.then? && isFunction x.then

---

      module.exports = {deepEqual, type, isType, instanceOf,
        isBoolean, isNumber, isNaN, isFinite, isInteger, isFloat,
        isString, isFunction, isObject, isArray, isDefined,
        isGenerator, isPromise}
