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
Globber = require '../lib/globber'

for pattern in process.argv.slice 2
  results = Globber.performGlob pattern, process.cwd()
  console.log "\x1b[33m#{pattern}\x1b[0m"
  for result in results
    console.log "\x1b[38;5;236m- \x1b[38;5;240m#{path.dirname result}/" +
      "\x1b[35m#{path.basename result}\x1b[0m"
