# Streamline - candidate for promotion. Doesn't quite work in practice.
# Probably rendered moot by Mutual

# Callback Management

$.streamline = (callback) ->
  (fn) ->
    (error,result) ->
      if error
        callback(error)
      else
        fn(result)

$.optimistic = (callback) ->
  (result) ->
    callback null, result
  
$.callbacks = {}

$.callbacks.logError = $.streamline (error) ->
  $.log error if error?

$.callbacks.fatalError = $.streamline (error) ->
  if error?
    $.log error
    $.abort
    
$.log = (thing) ->
  
  if thing instanceof Error
    {name,message} = thing
    process.stderr.write "#{name}: #{message}\n"
  else
    console.log "#{thing}"

$.fatalError = (error) ->
  $.log error
  $.abort()