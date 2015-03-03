# Using Fairmont Functions

When called from a script not named `test`, we should not see the tests run.

    {type} = require "../src/index"

    assert = require "assert"

    assert (type {}) == "object"
