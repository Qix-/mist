 #
 #     _|      _|  _|              _|
 #     _|_|  _|_|        _|_|_|  _|_|_|_|
 #     _|  _|  _|  _|  _|_|        _|
 #     _|      _|  _|      _|_|    _|
 #     _|      _|  _|  _|_|_|        _|_|
 #
 #             MIST BUILD SYSTEM
 # Copyright (c) 2015 On Demand Solutions, inc.

MistPostParser = require './mist-post-parser'
chalk = require 'chalk' # XXX DEBUG

## XXX DEBUG
inspect = (v)->console.log require('util').inspect v, colors: on, depth: null

expand = (str, vars)->
  str.replace /\$\(\s*([a-z0-9_]+)\s*\)/gi, (m, name, offset)->
    if not vars[name]? then throw {
      message: "variable not defined: #{name}"
      column: offset + 1
    }
    return vars[name]

doVariableAssignment = (line, enabled, vars)->
  return line

filters = [
  doVariableAssignment
]

processLines = (lines, map, options)->
  enabled = [yes]
  enabled.isEnabled = -> @[@.length - 1]
  vars = options.vars || options.vars = {}
  lines = lines.map (line, i)->
    try
      line = expand line, vars
    catch e
      e.line = i
      throw e
    for filter in filters
      line = filter line, enabled, vars, options
      if not line then return null
    return line
  lines = lines.filter (line, i)->
    if line is null
      map[i] = null
    return line?
  return lines

module.exports = (src, options = {})->
  lines = src.split /\r?\n/g
  map = [1..lines.length]

  try
    lines = processLines lines, map, options
    src = lines.join '\n'
    map = map.filter (m)-> m?
    console.log chalk.magenta src
    process.exit 0
#    MistPostParser.parse src, options
  catch e
    if e.constructor is String then e = message:e
    e.map = map
    throw e
