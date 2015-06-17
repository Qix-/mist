
#
#     _|      _|  _|              _|
#     _|_|  _|_|        _|_|_|  _|_|_|_|
#     _|  _|  _|  _|  _|_|        _|
#     _|      _|  _|      _|_|    _|
#     _|      _|  _|  _|_|_|        _|_|
#
#             MIST BUILD SYSTEM
# Copyright (c) 2015 On Demand Solutions, inc.

# This class resolves files given their base paths and mounts.
# This is the second step in fully rendering a Mist project.

# Implementations can take the result of this class and compile/render it
# any way they wish.

path = require 'path'
Globber = require './globber'

module.exports = class MistResolver
  constructor: (@rootDir, @rootMist)->
    # resolve globs
    @resolveGlobs()

    # resolve outputs
    # resolve groups
    # resolve commands

  ###
  # Resolves globs for files that exist on the filesystem itself
  ###
  resolveGlobs: ->
    for glob, arr of @rootMist.refs.globs
      Array::push.apply arr,
        Globber.performGlob glob, @rootDir
