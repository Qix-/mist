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

Command = config.constructor

(exports.build = new Command 'build')
  .description 'build the project'
(exports.glob = new Command 'glob [globs...]')
  .description 'test globs for file selection'

if path.basename(process.argv[1], '.js') is 'mist'
  config.executables = on
  config.defaultExecutable = 'build'
  for k, v of exports
    config.commands.push v
    config._execs[k] = on
  config
    .parse process.argv
