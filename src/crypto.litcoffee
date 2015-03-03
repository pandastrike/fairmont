# Hashing/Encoding Functions

    {describe, assert} = require "./helpers"

    describe "Crypto Functions", (context) ->

## md5

Return the MD5 hash of a string.

      md5 = (string) ->
        Crypto = require "crypto"
        Crypto.createHash('md5').update(string, 'utf-8').digest("hex")


      context.test "md5", ->
        assert (md5 "It was a dark and stormy night").trim?

## base64


Base64 encode a string. (Not URL safe.)

      base64 = (string) ->
        Crypto = require "crypto"
        new Buffer(string).toString('base64')

      context.test "base64", ->
        (base64 "It was a dark and stormy night").trim?


## base64url

Format a string as Base64, adapted based on [RFC 4648's][0] "base64url" mapping.

[0]:http://tools.ietf.org/html/rfc4648#section-5


      base64url = (string) ->
        Crypto = require "crypto"
        new Buffer(string)
        .toString('base64')
        .replace(/\+/g, '-')
        .replace(/\//g, '_')
        .replace(/\=+$/, '')

      context.test "base64url", ->
        (base64url "It was a dark and stormy night").trim?
---

      module.exports = {md5, base64, base64url}
