# Hashing/Encoding Functions

    Crypto = require "crypto"

## md5

Return the MD5 hash of a string.

    md5 = (string) ->
      Crypto.createHash('md5').update(string, 'utf-8').digest("hex")

## base64

Base64 encode a string. (Not URL safe.)

    base64 = (string) ->
      new Buffer(string).toString('base64').replace(/\=+$/, '')

## base64url

Format a string as Base64, adapted based on [RFC 4648's][0] "base64url" mapping.

[0]:http://tools.ietf.org/html/rfc4648#section-5

    base64url = (string) ->
      new Buffer(string)
      .toString('base64')
      .replace(/\+/g, '-')
      .replace(/\//g, '_')
      .replace(/\=+$/, '')

---

    module.exports = {md5, base64, base64url}
