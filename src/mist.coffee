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
config = require 'commander'
packageJson = require '../package'
Mist = require './mist-ninja-builder'

ninjaProc = process.env.NINJA || "#{__dirname}/ninja/ninja"

ninjaArgs = []
mistArgs = []
for a, i in process.argv.slice 2
  if a is '--'
    ninjaArgs = process.argv.slice i+3
    break
  else mistArgs.push a

config
  .version packageJson.version
  .parse mistArgs

try
  mistfile = Mist::findMistfile()
  if not mistfile 
    throw 'Mistfile not found (reached filesystem boundary)'
  mistdir = path.dirname mistfile

  console.log 'mist: evaporating Mistfile:', mistfile

  mist = new Mist mistdir
  mist.setNinjaProc ninjaProc
  mist.loadFile mistfile
  mist.run()
catch e
  throw e
