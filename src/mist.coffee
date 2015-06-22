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

config.command 'build'
  .description 'build the project'
  .action require './mist-build'
config.command 'clean'
  .description 'clean the project of all outputs'
  .action require './mist-clean'
config.command 'glob [globs...]'
  .description 'test file globbing patterns'
  .action require './mist-glob'
config.command 'render'
  .description 'render Ninja configuration to a file'
  .option '--out <file>', 'the filename of the rendered configuration',
    'build.ninja'
  .action require './mist-render'

# default
argv = process.argv
if 2 not of process.argv
  argv = process.argv.slice(0, 2).concat(['build']).concat process.argv.slice 2
else if process.argv[2] not of config._events
  if '--help' not in process.argv
    throw "unknown sub-command: #{process.argv[2]}"

config.parse argv
