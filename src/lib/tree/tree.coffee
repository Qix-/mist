#
#     _|      _|  _|              _|
#     _|_|  _|_|        _|_|_|  _|_|_|_|
#     _|  _|  _|  _|  _|_|        _|
#     _|      _|  _|      _|_|    _|
#     _|      _|  _|  _|_|_|        _|_|
#
#             MIST BUILD SYSTEM
# Copyright (c) 2015 On Demand Solutions, inc.

legos = require 'legos'

class Tree extends legos.Lego
  constructor: (structure)->
    # build up structure
    # TODO here is where you left off :)
    console.log require('util').inspect structure, colors:on,depth:null

module.exports = Tree
