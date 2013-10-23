assert = require "assert"
type = require "./type"

assert.type = (value, string) ->
  assert.equal type(value), string

assert.keys = (object, keys) ->
  assert.type object, "object"
  assert.deepEqual Object.keys(object).sort(), keys.sort()

assert.hasKeys = (object, keys) ->
  assert.type object, "object"
  for key in keys
    assert.ok object[key]?

assert.partialEqual = (actual, expected) ->
  assert.type actual, "object"
  for key, val of expected
    assert.deepEqual(actual[key], val)

module.exports = assert
