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
backslash = require 'backslash'

## XXX DEBUG
inspect = (v)->console.log require('util').inspect v, colors: on, depth: null

expand = (str, vars)->
  perform = ->
    str = str.replace /\$\(\s*([a-z0-9_]+)\s*\)/gi, (m, name, offset)->
      if name not of vars then throw {
        message: "variable not defined: #{name}"
        column: offset + 3 # +1 for 1-based offset, +2 for $(
      }
      return vars[name] || ''
  loop
    break if str is perform()
  return str

doVariableAssignment = (line, enabled, vars)->
  m = line.match /^[\s\t]*([a-z0-9_]+)[\s\t]*(\+?=)[\s\t]*(.+?)[\s\t]*$/i
  if m
    return null if not enabled.isEnabled()
    switch m[2]
      when '=' then vars[m[1]] = m[3]
      when '+=' then vars[m[1]] = "#{vars[m[1]]} #{m[3]}"
  return line

conditionals =
  ifeq: (args, v...)->
    (return false if val isnt v[0]) for val, i in val when i > 1
    return true
  ifneq: (args, v...)-> !(conditionals.ifeq.apply null, v)
  ifdef: (args, v...)->
    (return false if val not of args) for val, i in v
    return true
  ifndef: (args, v...)-> !(conditionals.ifdef.apply null, v)
conditionalsReg = /^[\s\t]*(@@@@)[\s\t]*\(([^\)\\]+(?:\\.[^\)\\]*)*)\)[\s\t]*$/
conditionalsReg = new RegExp conditionalsReg.source.replace '@@@@',
  (k for k,v of conditionals).join '|'

doConditional = (line, enabled, vars)->
  m = line.match conditionalsReg
  if m
    if enabled.isEnabled()
      cmp = conditionals[m[1]]
      args = m[2]
        .split /(?:\\\\)*\\,/g
        .map Function.prototype.call.bind String.prototype.trim
        .map backslash
      enabled.push cmp.apply null, [vars].concat args
    return null

  if /^\s*endif\s*$/.test line
    enabled.pop()
    return null

  if /^\s*else\s*$/.test line
    enabled[enabled.length - 1] = !enabled[enabled.length - 1]
    return null
  return line

filters = [
  doVariableAssignment
  doConditional
]

processLines = (lines, map, options)->
  enabled = [yes]
  enabled.isEnabled = -> (@indexOf no) is -1
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
#   console.log chalk.magenta src
#   process.exit 0
    MistPostParser.parse src, options
  catch e
    if e.constructor is String then e = message:e
    e.map = map
    throw e
