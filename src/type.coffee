#
## Type Functions ##
#

# ### type ###
#
# Get the type of a value. Possible values are: `number`, `string`, '`boolean`, `data`, `regexp`, `function`, `array`, `object`, `null`, `undefined`. Adapted from [The CoffeeScript Cookbook][type-0] and based on Douglas Crockford's [remedial JavaScript blog post][type-1].
# [type-0]:http://coffeescriptcookbook.com/chapters/classes_and_objects/type-function
# [type-1]:http://javascript.crockford.com/remedial.html
#
# ```coffee-script
# foo() if type( foo ) == "function"
# ```

classes = ["Boolean", "Number", "String", "Function",
  "Array", "Date", "RegExp"]
classToType = new Object
for name in classes
  classToType["[object " + name + "]"] = name.toLowerCase()

module.exports =
  type: (object) ->
    return "undefined" if object is undefined
    return "null" if object is null
    myClass = Object.prototype.toString.call object
    if myClass of classToType
      return classToType[myClass]
    else
      return "object"
