$ = {}

$.remove = (array, element) ->
  if (index = array.indexOf( element )) > -1
    array[index..index] = []
    element
  else
    null

$.uniq = (array, hash=(object)-> object.toString()) ->
  uniques = {}
  for element in array
    uniques[ hash(element) ] = element
  uniques[key] for key in Object.keys( uniques )

# Shuffle an array using Fisher-Yates algorithm: http://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle
# Adapted from: http://coffeescriptcookbook.com/chapters/arrays/shuffling-array-elements
$.shuffle = (array) ->
  copy = array[0..]
  return copy if copy.length <= 1
  for i in [copy.length-1..1]
    j = Math.floor Math.random() * (i + 1)
    # swap the i'th element with a randomly picked element in front of i
    [copy[i], copy[j]] = [copy[j], copy[i]]
  copy

module.exports = $
