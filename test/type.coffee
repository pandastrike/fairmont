assert = require "assert"
Amen = require "amen"

Amen.describe "Type functions", (context) ->

  {deepEqual, type, isType, instanceOf,
    isBoolean, isNumber, isNaN, isFinite, isInteger, isFloat,
    isString, isFunction, isObject, isArray, isRegExp, isDate, isDefined,
    isGenerator, isPromise} = require "../src/type"

  context.test "type"

  context.test "isType"

  context.test "instanceOf"

  context.test "isNumber", ->
    assert isNumber 7
    assert ! isNumber "7"
    assert ! isNumber false

  context.test "isNaN"
  context.test "isFinite"

  context.test "isInteger", ->
    assert isInteger 5
    assert ! isInteger 3.5
    assert ! isInteger "5"
    assert ! isInteger NaN

  context.test "isFloat", ->
    assert isFloat 3.5
    assert ! isFloat 5
    assert ! isFloat "3.5"
    assert ! isFloat NaN

  context.test "isBoolean", ->
    assert isBoolean true
    assert !isBoolean 7

  context.test "isDate", ->
    assert isDate (new Date)
    assert !isDate 7

  context.test "isRegExp", ->
    assert isRegExp /\s/
    assert !isRegExp 7

  context.test "isString", ->
    assert isString "x"
    assert !isString 7

  context.test "isFunction", ->
    assert isFunction ->
    assert !isFunction 7

  context.test "isObject", ->
    assert isObject {}
    assert !isObject 7

  context.test "isArray", ->
    assert isArray []
    assert !isArray 7

  isDefined = (x) -> x?

  context.test "isDefined", ->
    assert isDefined {}
    assert !isDefined undefined

  context.test "isGenerator", ->
    f = -> yield true
    assert isGenerator f

  isPromise = (x) -> x?.then? && isFunction x.then
