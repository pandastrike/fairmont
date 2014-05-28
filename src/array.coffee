$ = {}

# ## Array Functions ##

# ### remove ###
#
# Destructively remove an element from an array. Returns the element removed.
#
# ```coffee-script
# a = w "foo bar baz"
# remove( a, "bar" )
# ```

$.remove = (array, element) ->
  if (index = array.indexOf( element )) > -1
    array[index..index] = []
    element
  else
    null

# ### uniq ###
#
# Takes an array and returns a new array with all duplicate values from the original array removed. Also takes an optional hash function that defaults to calling `toString` on the elements.
#
# ```coffee-script
# uniq [1,2,3,1,2,3,4,5,6,3,6,2,4]
# # returns [1,2,3,4,5,6]
# ```


$.uniq = (array, hash=(object)-> object.toString()) ->
  uniques = {}
  for element in array
    uniques[ hash(element) ] = element
  uniques[key] for key in Object.keys( uniques )


# ### shuffle ###
#
# Takes an array and returns a new array with all values shuffled randomly.
# ```coffee-script
# shuffle ["a", "b", "c", "d", "e", "f"]
# # for e.g.: returns ["b", "c", "d", "e", "f", "a"]
# ```
#
# Use the [Fisher-Yates algorithm][shuffle-1].
#
# Adapted from the [CoffeeScript Cookbook][shuffle-2].
#
# [shuffle-1]:http://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle
# [shuffle-2]:http://coffeescriptcookbook.com/chapters/arrays/shuffling-array-elements

$.shuffle = (array) ->
  copy = array[0..]
  return copy if copy.length <= 1
  for i in [copy.length-1..1]
    j = Math.floor Math.random() * (i + 1)
    # swap the i'th element with a randomly picked element in front of i
    [copy[i], copy[j]] = [copy[j], copy[i]]
  copy

module.exports = $
