## Generator Functions

    {call, async} = do ->
      {lift, call} = require "when/generator"
      {async: lift, call}

    module.exports = {call, async}
