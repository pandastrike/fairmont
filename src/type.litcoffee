# Type Functions

    {curry}  = require "./core"

## type

Get the type of a value. Possible values are: `number`, `string`, '`boolean`, `date`, `regexp`, `function`, `array`, `object`, `null`, `undefined`.

    type = (x) -> x?.constructor

## isType

    isType = curry (t, x) -> type(x) == t

## instanceOf

    instanceOf = curry (t, x) -> x instanceof t

## isNumber

    isNumber = isType Number

## isNaN

    isNaN = (n) -> Number.isNaN n

## isFinite

    isFinite = (n) -> Number.isFinite n

## isInteger

    isInteger = (n) -> Number.isInteger n

## isFloat

Adapted from [StackOverflow][isFloat].

[isFloat]:http://stackoverflow.com/questions/3885817/how-to-check-if-a-number-is-float-or-integer/3885844#3885844

    isFloat = (n) -> n == +n && n != (n|0)

## isBoolean

    isBoolean = isType Boolean

## isDate

    isDate = isType Date

## isRegExp

    isRegExp = isType RegExp

## isString

    isString = isType String

## isFunction

    isFunction = isType Function

## isObject

    isObject = isType Object

## isArray

    isArray = isType Array

## isDefined

    isDefined = (x) -> x?

## isGenerator

    GeneratorFunction = (-> yield null).constructor

    isGenerator = isType GeneratorFunction

## isPromise

    isPromise = (x) -> x?.then? && isFunction x.then

---

    module.exports = {type, isType, instanceOf,
      isBoolean, isNumber, isNaN, isFinite, isInteger, isFloat,
      isString, isFunction, isObject, isArray, isDefined,
      isRegExp, isDate, isGenerator, isPromise}
