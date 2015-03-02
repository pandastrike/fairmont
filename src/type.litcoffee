# Type Functions

    {curry} = require "./core"

## type

Get the type of a value. Possible values are: `number`, `string`, '`boolean`, `data`, `regexp`, `function`, `array`, `object`, `null`, `undefined`.

    type = (x) -> Object::toString.call(x).slice(8, -1).toLowerCase()

## is_type

    is_type = curry (t, x) -> type(x) == t

## instance_of

    instance_of = curry (t, x) -> x instanceof t

---
    module.exports = {type, is_type, instance_of}
