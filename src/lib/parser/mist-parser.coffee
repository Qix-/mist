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

###
# Removes all comments from the file
###
RemoveComments = (src)-> src.replace /((?!\\).|^)#.*$/gm, '$1'

###
# Removes all double newlines
###
RemoveDoubleNL = (src)-> src.replace /(\r?\n){2,}/g, '$1'

###
# Removes leading spaces
###
RemoveLeadingSpace = (src)-> src.replace /^[\s\t]*/gm, ''

###
# Conditional Processor
###
ConditionalOperators =
  eq: (a, b)-> a is b
  neq: (a,b)-> a isnt b
  def: (a)-> a?
  ndef: (a)-> not a?
opreg = /^if(@@@@@@)\s*\(\s*((?:(?:'[^']*')|(?:"[^"]*")|(?:[^,\)]+))(?:,(?:(?:'[^']*')|(?:"[^"]*")|(?:[^,\)]+)))*)\s*\)\s*$/
opreg = new RegExp opreg.source.replace '@@@@@@',
  Object.keys(ConditionalOperators).join '|'
ParseConditional = (line, vars)->
  arglist = line.match opreg
  if not arglist then return null
  operator = ConditionalOperators[arglist[1]]
  arglist = arglist[2]
  args = []
  arglist.replace /(?:(?:'([^']*)')|(?:"([^"]*)")|([^,\)]+))/g,
    (m, str, strd, env)->
      str = str || strd
      if env then return args.push vars[env]
      if str then return args.push str
  return operator.apply null, args
ConditionalProcessor = (src, vars = {})->
  enabled = [yes]
  src
    .split /[\r\n]+/g
    .filter (line)->
      result = ParseConditional line, vars
      if result is null
        if line.match(/^\s*endif\s*$/) isnt null
          enabled.pop()
          return false
        else
          return enabled[enabled.length-1]
      else
        enabled.push result
        return false
    .join '\n'

module.exports = (src, opts)->
  [
    RemoveComments
    RemoveDoubleNL
    RemoveLeadingSpace
    (src)-> ConditionalProcessor src, opts.vars
    (src)-> MistPostParser.parse src, opts
  ].reduce ((src, fn)-> fn src), src
