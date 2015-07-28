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
docoptmd = require 'docoptmd'
docoptCleanse = require 'docopt-cleanse'
packageJson = require '../package'

# try to install source map support, if it's enabled (dev mode)
try
  (require 'source-map-support').install()

# action wrapper
# we wrap action functions due to the fact the bootstrap process
# only builds the bare-necessities. this function requires on demand,
# not on every run.
wrapAction = (name)->-> (require name).apply null,
  Array.prototype.slice.call(arguments).concat prettyError

# configuration
config = docoptmd path.dirname __dirname

# default?
found = false
for k, v of config when /^[a-z]+$/i.test k
  if v
    found = true
    break

if not found then config.build = true

# deliberate
for k, v of config when v and /^[a-z]+$/i.test k
  # fix parameters
  config = docoptCleanse config
  (require "./mist-#{k}") config, prettyError
  break
