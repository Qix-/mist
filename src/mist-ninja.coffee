#
#     _|      _|  _|              _|
#     _|_|  _|_|        _|_|_|  _|_|_|_|
#     _|  _|  _|  _|  _|_|        _|
#     _|      _|  _|      _|_|    _|
#     _|      _|  _|  _|_|_|        _|_|
#
#             MIST BUILD SYSTEM
# Copyright (c) 2015 On Demand Solutions, inc.

# This class has a few moving parts. First, you set up
# the target configuration tree via the MistNinja class.
#
# From there, you perform a resolution. Resolution occurs
# by taking all paths and mounts and resolving the path
# to them.

module.exports = class MistNinja
  constructor: ->
    @mounts = []

  resolve: (root)->

  mount: (mist, path)->
    @mounts.push
      mist: mist
      path: path
