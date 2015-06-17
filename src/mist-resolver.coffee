
#
#     _|      _|  _|              _|
#     _|_|  _|_|        _|_|_|  _|_|_|_|
#     _|  _|  _|  _|  _|_|        _|
#     _|      _|  _|      _|_|    _|
#     _|      _|  _|  _|_|_|        _|_|
#
#             MIST BUILD SYSTEM
# Copyright (c) 2015 On Demand Solutions, inc.

# This class resolves files given their base paths and mounts.
# This is the second step in fully rendering a Mist project.

# Implementations can take the result of this class and compile/render it
# any way they wish.

path = require 'path'
Globber = require './globber'
Hasher = require './hasher'

module.exports = class MistResolver
  constructor: (@rootDir, @rootMist)->
    # resolve globs
    @resolveGlobs()

  ###
  # Resolves globs for files that exist on the filesystem itself
  ###
  resolveGlobs: ->
    for rule in @rootMist.rules
      # inputs
      for input in rule.src.inputs
        if input.type is 'glob'
          results = Globber.performGlob input.value, @rootDir
          @processInput rule, result for result in results

  processInput: (rule, input)->
    return if input of rule.targets

    rule.targets[input] =
      dependencies: MistResolver.delimitPaths input, rule.src.dependencies

###
# Make sure to always include `$1` in the replacement
###
MistResolver.delimiterPattern = /((?!\%).)?%([fbB])/g

###
# Returns whether or not a string has filename delimiters present
#
# str:
#   The string to check
###
MistResolver.hasDelimiters = (str)->
  !!(str.match MistResolver.delimiterPattern)

###
# Delimites a number of templates given a pathname
#
# pathname:
#   The pathname to use when expanding the templates
# templates:
#   An array of delimited templates
###
MistResolver.delimitPaths = (pathname, templates)->
  dict = {}
  dict['f'] = pathname
  dict['b'] = path.basename pathname
  dict['B'] = dict['b'].replace /\..+$/, ''

  templates.map (template)->
    template.replace MistResolver.delimiterPattern, (m, p, c)->
      if c of dict then p + dict[c]
      else throw "unknown file delimiter: #{c}"
