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

config = require 'commander'
packageJson = require '../package'

config
  .version packageJson.version
config
  .command 'build [options]', 'build the project', isDefault: yes
config
  .command 'glob [globs...]', 'test globs for file selection'
config
  .parse process.argv
