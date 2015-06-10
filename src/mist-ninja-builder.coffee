 #
 #     _|      _|  _|              _|
 #     _|_|  _|_|        _|_|_|  _|_|_|_|
 #     _|  _|  _|  _|  _|_|        _|
 #     _|      _|  _|      _|_|    _|
 #     _|      _|  _|  _|_|_|        _|_|
 #
 #             MIST BUILD SYSTEM
 # Copyright (c) 2015 On Demand Solutions, inc.

path = require 'path'

module.exports = class MistNinjaBuilder
  construct: (@rootDir, @mistDir)->
    @reg =
      rules: {}
      vars: [
        ['ninja_required_version', '1.5.0']
        ['builddir', path.join @rootDir, '.mist']
      ]
      groups: {}
      targets: []

  render: -> ''
  run: (exArgs = [])->
