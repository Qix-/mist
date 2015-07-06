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
Globber = require '../lib/util/globber'

module.exports = (globs, config)->
  for pattern in globs
    results = Globber.performGlob pattern, process.cwd()
    console.log "\x1b[33m#{pattern}\x1b[0m"
    for result in results
      console.log "\x1b[38;5;236m- \x1b[38;5;240m#{path.dirname result}/" +
        "\x1b[35m#{path.basename result}\x1b[0m"
