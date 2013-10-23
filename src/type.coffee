# type - reliable, consistent type function. Adapted from:
# http://coffeescriptcookbook.com/chapters/classes_and_objects/type-function
# See also, of course: http://javascript.crockford.com/remedial.html

classToType = new Object
for name in ["Boolean", "Number", "String", "Function", "Array", "Date", "RegExp"]
  classToType["[object " + name + "]"] = name.toLowerCase()

module.exports = (object) ->
  return "undefined" if object is undefined
  return "null" if object is null
  myClass = Object.prototype.toString.call object
  if myClass of classToType
    return classToType[myClass]
  else
    return "object"

