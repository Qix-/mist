#
#     _|      _|  _|              _|
#     _|_|  _|_|        _|_|_|  _|_|_|_|
#     _|  _|  _|  _|  _|_|        _|
#     _|      _|  _|      _|_|    _|
#     _|      _|  _|  _|_|_|        _|_|
#
#             MIST BUILD SYSTEM
# Copyright (c) 2015 On Demand Solutions, inc.

xxhash = require 'xxhash'

xxHashSeed = (parseInt 'AEROMIST', 30) >> 2

module.exports.hash = (str, first = yes)->
  cmdHash = xxhash.hash (new Buffer str), xxHashSeed
  v = cmdHash.toString 36
  if first
    m = str.match /^\s*([a-z0-9\-\_]+)/i
    if m and m[1] then v = "#{m[1]}_#{v}"
  return v
