$ = {}

#
# ## Hashing/Encoding Functions
#

#
# ### md5 ###
#
# Return the MD5 hash of a string.
#
# ```coffee-script
# nutshell = md5( myLifeStory )
# ```

$.md5 = (string) ->
  Crypto = require "crypto"
  Crypto.createHash('md5').update(string, 'utf-8').digest("hex")


#
# ### base64 ###
#
# Base64 encode a string. (Not URL safe.)
#
# ```coffee-script
# image = data: base64( imageData )
# ```

$.base64 = (string) ->
  Crypto = require "crypto"
  new Buffer(string).toString('base64')

module.exports = $
