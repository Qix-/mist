
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

# The methodology for the resolver:
# 1) Generate templates for (order) dependencies and (aux) outputs
# 2) Generate a separate target for each globbed input
# 3) Run each resulting input through the previously generated templates
# 4) Run generated outputs as inputs for each rule relying on target group
# 4) Compile down non-foreach rules
# 5) Pass off to renderer

path = require 'path'
Globber = require './globber'
Hasher = require './hasher'

module.exports = class MistResolver
  constructor: (@rootDir, @rootMist)->
    # generate templates
    @generateTemplates()

  ###
  # Generates templates for dependencies and outputs
  ###
  generateTemplates: ->
    mktm = (i)=> @makeTemplate i

    for rule in @rootMist.rules
      rule.templates =
        dependencies: rule.src.dependencies.map mktm
        orderDependencies: rule.src.orderDependencies.map mktm
        outputs: rule.src.outputs.map mktm
        auxOutputs: rule.src.auxOutputs.map mktm

  ###
  # Transforms a source input into a template function
  #
  # input:
  #   The input pair generated from the parser
  ###
  makeTemplate: (input)->
    switch input.type
      when 'glob' then (path, group)=>
        [] if group?
        path = MistResolver.delimitPath path, input.value
        Globber.performGlob path, @rootDir
      when 'group' then (path, group)->
        if group is input.value then [path] else []
      when 'simple' then (path, group)->
        [] if group?
        MistResolver.delimitPath path, input.value
      else
        throw "unknown input type: #{input.type}"
  ###
  # Resolves globs for files that exist on the filesystem itself
  ###
  resolveRules: ->
    for rule in @rootMist.rules
      # generate templates

      # inputs
      for input in rule.src.inputs
        if input.type is 'glob'
          results = Globber.performGlob input.value, @rootDir
          @processInput rule, result for result in results

  ###
  # Processes the input for a rule and compiles a number of targets for the
  # rule, pushing outputs to associated groups.
  #
  # This is the meat of Mist.
  #
  # rule:
  #   The rule for which to add an input
  # input:
  #   The input to process
  ###
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
# Delimits a template given a pathname
#
# Memoized!
#
# pathname:
#   The pathname to use when expanding the templates
# template:
#   A delimited template
###
MistResolver.delimitPath = (pathname, templates)->
  dict = {}
  if pathname of @
    dict = @[pathname]
  else
    dict['f'] = pathname
    dict['b'] = path.basename pathname
    dict['B'] = dict['b'].replace /\..+$/, ''

  template.replace MistResolver.delimiterPattern, (m, p, c)->
    if c of dict then p + dict[c]
    else throw "unknown file delimiter: #{c}"

MistResolver.delimitPath = MistResolver.delimitPath.bind {}
