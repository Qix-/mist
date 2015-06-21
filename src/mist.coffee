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

exports.config =
  config
    .version packageJson.version

exports.options =
  build:
    config
      .command 'build [options]', 'build the project', isDefault: yes
  glob:
    config
      .command 'glob [globs...]', 'test globs for file selection'

if path.basename(process.argv[1], '.js') is 'mist'
  config
    .parse process.argv
