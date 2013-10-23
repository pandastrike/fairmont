$ = {}

$.md5 = (string) ->
  Crypto = require "crypto"
  Crypto.createHash('md5').update(string, 'utf-8').digest("hex")

$.base64 = (string) ->
  Crypto = require "crypto"
  new Buffer(string).toString('base64')

module.exports = $
