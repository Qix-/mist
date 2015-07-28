#
#     _|      _|  _|              _|
#     _|_|  _|_|        _|_|_|  _|_|_|_|
#     _|  _|  _|  _|  _|_|        _|
#     _|      _|  _|      _|_|    _|
#     _|      _|  _|  _|_|_|        _|_|
#
#             MIST BUILD SYSTEM
# Copyright (c) 2015 On Demand Solutions, inc.

module.exports = (config, cb)->
  path = require 'path'
  Mistfile = require '../'
  NinjaRenderer = require '../lib/renderer/ninja'

  ninjaProc = process.env.NINJA || "#{__dirname}/ninja/ninja"

  Mistfile.find config.cwd, (err, mistfile)->
    if err then return cb err
    mistfile.run config.backend, cb
