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

module.exports = class Mistfile
  constructor: ->
    @mounts = []

  ###
  # Creates a new resolver for this mistfile.
  #
  # Should only be called on the root-most Mistfile.
  #
  # root:
  #   Absolute path for this mistfile (the folder to resolve against)
  ###
  resolve: (root)->
    new MistResolver root, @

  ###
  # Mount another Mistfile at a specific relative path
  #
  # mist
  #   The Mistfile object to mount
  # path
  #   The path relative to this file for where the Mistfile is
  #   (for resolution)
  ###
  mount: (mist, path)->
    @mounts.push
      mist: mist
      path: path
