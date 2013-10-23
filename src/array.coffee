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

module.exports = $
