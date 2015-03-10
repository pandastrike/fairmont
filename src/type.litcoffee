# Type Functions

    {curry, deep_equal} = require "./core"

    {describe, assert} = require "./helpers"

    describe "Type functions", (context) ->

## deep_equal

This is actually defined in `core` to avoid circular dependences. However, we require and export it here, since this is where it logically belongs.

## type

Get the type of a value. Possible values are: `number`, `string`, '`boolean`, `data`, `regexp`, `function`, `array`, `object`, `null`, `undefined`.

      type = (x) -> Object::toString.call(x).slice(8, -1).toLowerCase()

      context.test "type"

## is_type

      is_type = curry (t, x) -> type(x) == t

      context.test "is_type"

## instance_of

      instance_of = curry (t, x) -> x instanceof t

      context.test "instance_of"

## is_string

      is_string = (x) -> x.trim?

## is_function

      is_function = (x) -> x.call?

---

      module.exports = {deep_equal, type, is_type, instance_of,
        is_string, is_function}
