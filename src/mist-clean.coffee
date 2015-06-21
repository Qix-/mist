 #
 #     _|      _|  _|              _|
 #     _|_|  _|_|        _|_|_|  _|_|_|_|
 #     _|  _|  _|  _|  _|_|        _|
 #     _|      _|  _|      _|_|    _|
 #     _|      _|  _|  _|_|_|        _|_|
 #
 #             MIST BUILD SYSTEM
 # Copyright (c) 2015 On Demand Solutions, inc.

try
  (require 'source-map-support').install()

path = require 'path'
Mistfile = require '../lib/mistfile'
NinjaRenderer = require '../lib/renderer/ninja'
config = (require './mist').clean

ninjaProc = process.env.NINJA || "#{__dirname}/ninja/ninja"

config.parse process.argv

mistfile = Mistfile.find()
if not mistfile
  throw 'Mistfile not found (reached filesystem boundary)'
mistdir = path.dirname mistfile

console.log 'mist: evaporating Mistfile:', mistfile

mist = Mistfile.fromFile mistfile
resolver = mist.resolve mistdir
NinjaRenderer.run resolver, ['-t', 'clean'], ninjaProc
