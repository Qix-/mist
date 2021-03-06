
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
# 2) Generate a separate target for each globbed/grouped input
# 3) Run each resulting input through the previously generated templates
# 4) Run generated outputs as inputs for each rule relying on target group
# 4) Compile down non-foreach rules
# 5) Pass off to renderer

path = require 'path'
Globber = require './globber'
Hasher = require './hasher'

module.exports = class MistResolver
  constructor: (@rootDir, @rootMist)->
    @groupRefs = {}

    @compileCommands()
    @setupTargets()
    @generateTemplates()
    @generateTargets()

  ###
  # Compiles all commands
  ###
  compileCommands: ->
    for rule in @rootMist.rules
      rule.command =
        hash: Hasher.hash rule.src.command
        command: MistResolver.delimitCommand rule.src.command

  ###
  # Creates a targets object for each rule
  ###
  setupTargets: ->
    for rule in @rootMist.rules
      rule.targets = {}

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
  # rule:
  #   The rule for this input
  ###
  makeTemplate: (input, rule)->
    switch input.type
      when 'glob' then (path, group)=>
        [] if group?
        path = MistResolver.delimitPath path, input.value
        Globber.performGlob path, @rootDir
      when 'group'
        @groupRefs[input.value] = @groupRefs[input.value] || []
      when 'simple' then (path, group)->
        [] if group?
        MistResolver.delimitPath path, input.value
      else
        throw "unknown template type: #{input.type}"

  ###
  # Iterates all inputs and generates target outputs,
  # supplying groups with targets as well
  ###
  generateTargets: ->
    groupSubs = {}
    for rule in @rootMist.rules
      for input in rule.src.inputs
        if input.type is 'group'
          (groupSubs[input.value] = groupSubs[input.value] || []).push rule

    for rule in @rootMist.rules
      for input in rule.src.inputs
        switch input.type
          when 'glob'
            results = Globber.performGlob input.value, @rootDir
            for result in results
              @processInput rule, result, null, groupSubs
          when 'group' then break
          else
            throw "unknown input type: #{input.type}"

  ###
  # Gives a single input to a rule for processing
  #
  # rule:
  #   The rule for which to create a target based on the input
  # input:
  #   The input for which to create a target
  # group:
  #   A group, if any, that triggered the input
  # groupSubs:
  #   A dictionary of group=>rules that are subscribed to receive
  #   target outputs as inputs to process
  ###
  processInput: (rule, input, group, groupSubs = {})->
    return if input of rule.targets

    processor = (fn)->
      if fn instanceof Function
        fn input, group
      else
        fn

    rule.targets[input] =
      dependencies: rule.templates.dependencies.map processor
      orderDependencies: rule.templates.orderDependencies.map processor
      outputs: rule.templates.outputs.map processor
      auxOutputs: rule.templates.auxOutputs.map processor

    for k, a of rule.targets[input]
      rule.targets[input][k] = a.flatten()

    for group in rule.src.groups
      for output in rule.targets[input].outputs
        (@groupRefs[group] = @groupRefs[group] || []).push output
        if group of groupSubs
          for rule in groupSubs[group]
            @processInput rule, output, group, groupSubs

    return null

  ###
  # Compiles the resolved tree into a raw target list
  ###
  compile: ->
    result =
      targets: []
      commands: {}

    for rule in @rootMist.rules
      result.commands[rule.command.hash] =
        command: rule.command.command

      if rule.src.foreach
        for input, target of rule.targets
          outputs = target.outputs.compile()
          inputs = [input]
          result.targets.push
            command:
              name: rule.command.hash
              vars: MistResolver.compileVars inputs, outputs
            inputs: inputs
            dependencies: target.dependencies.compile()
            orderDependencies: target.orderDependencies.compile()
            outputs: outputs
            auxOutputs: target.auxOutputs.compile()
      else
        inputs = (k for k of rule.targets).compile()
        outputs = (v.outputs for k, v of rule.targets).compile()
        result.targets.push
          command:
            name: rule.command.hash
            vars: MistResolver.compileVars inputs, outputs
          inputs: inputs
          dependencies:
            (v.dependencies for k, v of rule.targets).compile()
          orderDependencies:
            (v.orderDependencies for k, v of rule.targets).compile()
          outputs: outputs
          auxOutputs:
            (v.auxOutputs for k, v of rule.targets).compile()

    return result
###
# Make sure to always include `$1` in the replacement
###
MistResolver.delimiterPattern = /%(-?\d+-?(?:,-?\d+-?)*(?=d))?([%fFbBoOd])/g

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
# pathname:
#   The pathname to use when expanding the templates
# template:
#   A delimited template
###
MistResolver.delimitPath = (pathname, template)->
  dict = MistResolver.generateDict pathname

  template.replace MistResolver.delimiterPattern, (m, p, c)->
    c = (p || '') + c
    if c of dict then dict[c]
    else throw "unknown file delimiter: #{c}"

###
# Generates a delimiter dictionary for a given pathname.
#
# Implemented with memoization for slightly better performance.
#
# pathname;
#   The pathname for which to build up a dictionary
###
MistResolver.generateDict = (pathname)->
  dict = {}
  if pathname of @
    dict = @[pathname]
  else
    dict['%'] = '%'
    dict['x'] = path.extname pathname
    dict['b'] = path.basename pathname
    dict['X'] = dict['b'].replace /.+?(\..+)$/, '$1'
    dict['B'] = path.basename dict['b'], dict['x']
    dict['f'] = pathname
    dict['F'] = path.basename dict['f'], dict['x']
    dict['o'] = '%o'
    dict['O'] = '%O'

    leafs = path.dirname(pathname).split path.sep
    len = leafs.length
    pathJoinArray = (arr)-> path.join.apply path, arr
    for leaf,i in leafs
      ii = i + 1
      ni = len - ii
      dict["#{ii}d"] = leaf
      dict["#{ii}-d"] = pathJoinArray leafs.slice i
      dict["-#{ii}d"] = leafs[ni]
      dict["-#{ii}-d"] = pathJoinArray leafs.slice ni
  return dict
MistResolver.generateDict = MistResolver.generateDict.bind {}

###
# Delimits a command
#
# command:
#   The command to delimit
###
MistResolver.delimitCommand = (command)->
  command.replace MistResolver.delimiterPattern, (m, c, d)->
    if d is '%' then '%'
    c = (c || '').replace '-', '_'
    "${D_#{c}#{d}}"

MistResolver.compileVars = (inputs, outputs)->
  result = {}
  outputDirs = outputs.map path.dirname
  for input in inputs.map MistResolver.generateDict
    for k, v of input
      if k is '%' then continue
      if k is 'o' then v = outputs
      if k is 'O' then v = outputDirs
      k = k.replace '-', '_'
      k = "D_#{k}"
      result[k] = [] if k not of result
      result[k] = result[k].concat v
  for k, v of result
    result[k] = v.unique().linearize()
  return result
