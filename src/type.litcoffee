# Type Functions

    {curry, deep_equal} = require "./core"

    {describe, assert} = require "./helpers"

    describe "Type functions", (context) ->

## deep_equal

This is actually defined in `core` to avoid circular dependences. However, we require and export it here, since this is where it logically belongs.

## type

Get the type of a value. Possible values are: `number`, `string`, '`boolean`, `date`, `regexp`, `function`, `array`, `object`, `null`, `undefined`.

      type = (x) -> Object::toString.call(x).slice(8, -1).toLowerCase()

      context.test "type"

## is_type

      is_type = curry (t, x) -> type(x) == t

      context.test "is_type"

## instance_of

      instance_of = curry (t, x) -> x instanceof t

      context.test "instance_of"

## is_number

      is_number = is_type "number"

      context.test "is_number", ->
        assert is_number 7
        assert !is_number false

## is_boolean

      is_boolean = is_type "boolean"

      context.test "is_boolean", ->
        assert is_boolean true
        assert !is_boolean 7

## is_date

      is_date = is_type "date"

      context.test "is_date", ->
        assert is_date (new Date)
        assert !is_date 7

## is_regexp

      is_regexp = is_type "regexp"

      context.test "is_regexp", ->
        assert is_regexp /\s/
        assert !is_regexp 7

## is_string

      is_string = is_type "string"

      context.test "is_string", ->
        assert is_string "x"
        assert !is_string 7

## is_function

      is_function = is_type "function"

      context.test "is_function", ->
        assert is_function ->
        assert !is_function 7

## is_generator

      is_generator = (x) ->
        x.constructor.name == "GeneratorFunction"

      context.test "is_generator", ->
        f = -> yield true
        assert is_generator f

## is_object

      is_object = is_type "object"

      context.test "is_object", ->
        assert is_object {}
        assert !is_object 7

## is_array

      is_array = is_type "array"

      context.test "is_array", ->
        assert is_array []
        assert !is_array 7

## is_value

      is_value = (x) -> x?

      context.test "is_value", ->
        assert is_value {}
        assert !is_value undefined

---

      module.exports = {deep_equal, type, is_type, instance_of,
        is_boolean, is_number, is_string, is_function, is_generator,
        is_object, is_array, is_value}
