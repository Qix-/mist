#
#     _|      _|  _|              _|
#     _|_|  _|_|        _|_|_|  _|_|_|_|
#     _|  _|  _|  _|  _|_|        _|
#     _|      _|  _|      _|_|    _|
#     _|      _|  _|  _|_|_|        _|_|
#
#             MIST BUILD SYSTEM
# Copyright (c) 2015 On Demand Solutions, inc.

fs = require 'fs'
readFd = require 'read-fd'
findHigherFile = require 'find-higher-file'
parseMist = require './parser/mist-parser'

class Mist
  constructor: (@source, @filename, @opts = {})->
    @tree = null

    if arguments.length <= 2
      if arguments.length < 1
        throw 'you must specify a filename'
      @filename = @source
      @source = fs.readFileSync(@filename).toString()

  run: (backend, cb)->
    try
      back = require "./backend/#{backend}"
    catch e
      return cb e

    @process (err)->
      if err then return cb err
      back.run @, cb

  process: (cb)->
    if @tree then return cb null, @tree

    # run through the parser
    structure = null
    try
      structure = parseMist @source
    catch e
      cb e

    console.log require('util').inspect structure, colors:on,depth:null

Mist.find = (from = process.cwd(), opts, cb)->
  if arguments.length is 2
    cb = opts
    opts = {}
  findHigherFile 'Mistfile', from, find:'highest', (err, fd, name)->
    if err then return cb err
    readFd fd, (err, data)->
      if err then return cb err
      cb null, new Mist data.toString(), name, opts

module.exports = Mist
