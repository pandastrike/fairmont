# Tests

We're playing a bit of a trick here. The source files [require `helpers`][0], which checks to see if the script is named `test`. If so, Amen and Node's assert API are exported. Otherwise, they're pass-throughs.

[0]:./src/helpers.litcoffee

    require "../src/index"
