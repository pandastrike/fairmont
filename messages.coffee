# Beginnings of an message catalog with interface for 
# dealing with errors and exceptions. Candidate for promotion.
# Doesn't *quite* work as is, in practice. See ./fibers for
# an example.

$.Catalog = 
  messages: {}
  errors: {}
  add: (messages) ->
    for key,fn of messages
      $.Catalog.messages[key] = fn
      $.Catalog.errors[key] = (args...) ->
        new Error fn args...
    $.Catalog

$.message = (key) -> $.Catalog.messages[key]

$.toError = (thing,args...) -> 
  switch ($.type thing)
    when "string"
      if errorFunction = $.Catalog.errors[thing]
        errorFunction args...
      else
        new Error thing
    else
      $.to Error, thing
      
$.throwError = (args...) ->
  throw ($.toError args...)

