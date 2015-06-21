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

fs = require 'fs'
path = require 'path'
Mistfile = require '../lib/mistfile'
NinjaRenderer = require '../lib/renderer/ninja'
config = (require './mist').render

config.parse process.argv

mistfile = Mistfile.find()
if not mistfile
  throw 'Mistfile not found (reached filesystem boundary)'
mistdir = path.dirname mistfile

console.log 'mist: evaporating Mistfile:', mistfile

mist = Mistfile.fromFile mistfile
resolver = mist.resolve mistdir
rendered = NinjaRenderer.render resolver
fs.writeFileSync config.out, rendered
console.log 'mist: rendered to', config.out