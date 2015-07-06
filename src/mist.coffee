#
#     _|      _|  _|              _|
#     _|_|  _|_|        _|_|_|  _|_|_|_|
#     _|  _|  _|  _|  _|_|        _|
#     _|      _|  _|      _|_|    _|
#     _|      _|  _|  _|_|_|        _|_|
#
#             MIST BUILD SYSTEM
# Copyright (c) 2015 On Demand Solutions, inc.

prettyError = require '../lib/util/pretty-error'
path = require 'path'
config = require 'commander'
packageJson = require '../package'

try
  (require 'source-map-support').install()

try
  # action wrapper
  # we wrap action functions due to the fact the bootstrap process
  # only builds the bare-necessities. this function requires on demand,
  # not on every run.
  wrapAction = (name)->-> (require name).apply null, arguments

  # basic configuration
  config.cwd = process.cwd()

  config.version packageJson.version
  config.command 'build'
    .description 'build the project'
    .action wrapAction './mist-build'
  config.command 'clean'
    .description 'clean the project of all outputs'
    .action wrapAction './mist-clean'
  config.command 'glob [globs...]'
    .description 'test file globbing patterns'
    .action wrapAction './mist-glob'
  config.command 'render'
    .description 'render Ninja configuration to a file'
    .option '--out <file>', 'the filename of the rendered configuration',
      'build.ninja'
    .action wrapAction './mist-render'

  # default
  argv = process.argv
  if 2 not of process.argv
    argv = process.argv.slice(0, 2).concat(['build']).concat process.argv.slice 2
  else if process.argv[2] not of config._events
    if '--help' not in process.argv
      throw "unknown sub-command: #{process.argv[2]}"

  config.parse argv
catch e
  prettyError e
