 #
 #     _|      _|  _|              _|
 #     _|_|  _|_|        _|_|_|  _|_|_|_|
 #     _|  _|  _|  _|  _|_|        _|
 #     _|      _|  _|      _|_|    _|
 #     _|      _|  _|  _|_|_|        _|_|
 #
 #             MIST BUILD SYSTEM
 # Copyright (c) 2015 On Demand Solutions, inc.

xxhash = require 'xxhash'
MistGlobber = require './mist-globber'

xxHashSeed = (parseInt 'AEROMIST', 30) >> 2

module.exports = class MistNinjaBuilder
  constructor: (@registry = {})->
    @rootDir
    @registry.vars = @registry.vars || []
    @registry.rules = @registry.rules || {}
    @registry.targets = @registry.rules || []

  setRootDir: (@rootDir)->
  setDir: (@mistDir)->

  setVar: (name, val)->
    @registry.vars.push name:name, val:val

  addRule: (name, command, vars = {})->
    if @registry.rules[name]?
      throw "attempt to add duplicate rule '#{name}'"
    @registry.rules[name] = rule = command:command
    for k,v of vars
      rule[k] = v

  addRuleHash: (command, vars = {})->
    hash = MistNinjaBuilder.hashCommand command
    @addRule hash, command, vars

  expand: (str)->
    str.replace /\$\{([^\}]+)\}/g, (m, name) =>
      # TODO error?
      @registry.vars[name] || ''

  addTarget: (statement)->
    # perform glob
    inFiles =
      main_inputs: MistGlobber.doAllGlobs statement.main_inputs, @mistDir
      dep_inputs: MistGlobber.doAllGlobs statement.dep_inputs, @mistDir
      order_inputs: MistGlobber.doAllGlobs statement.order_inputs, @mistDir
      main_outputs: statement.main_outputs.unique()
      aux_outputs: statement.aux_outputs.unique()

    # some logic:
    #   FOREACH
    #     ran for each input
    #     deps honor delims per file
    #     odeps honor delims per file
    #     command honors delims per file
    #     outputs honor delims per file; must have at least one
    #     aux outputs honor delims per file; must have at least one
    #   SINGLE
    #     ran once for all inputs
    #     deps with delims generate for each file and flatten array
    #     deps with no delims appear once, verbatim
    #     odeps with delims generate for each file and flatten array
    #     odeps with no delims appear once, verbatim
    #     command honors delims, but still inserts all
    #     outputs honor delims for each file and flatten array
    #     aux-outputs honor delims for each file and flatten array

    # setup regexes
    noForeachReg = /\%[fo]/g
    foreachReg = /\%[fo]/g

    # transform the command
    #command = if statement.foreach


    # hash the transformed commmand
    commandHash = MistNinjaBuilder.hashCommand statement.command

    # add the rule
    try
      @addRule commandHash, statement.command
      # we silently ignore duplicates

    #if statement.foreach

  render: ->
    lines = []
    lines.pushScoped = (v)-> @push "  #{v}"

    if @rootDir?
      lines.push "builddir=#{@rootDir}"
      lines.push "ninja_required_version=1.5.3"

    for pair in @registry.vars
      lines.push "#{pair.name}=#{pair.val}"

    for rule, vars of @registry.rules
      lines.push "rule #{rule}"
      for k,v of vars
        lines.pushScoped "#{k}=#{v}"

    for target in @registry.targets
      lines.push "build #{target.outputs.join ' '}: " +
           "#{if target.phony then "phony"} #{target.rule} " +
           "#{target.inputs.join ' '}" +
           "#{if target.deps.length then " | "}#{target.deps.join ' '}" +
           "#{if target.odeps.length then " || "}#{target.deps.join ' '}"
      for k,v of target.vars
        lines.pushScoped "#{k}=#{v}"

    lines.push '' # Ninja requires a newline at the end :)
    lines.join '\n'

MistNinjaBuilder.hashCommand = (command)->
  # we use xxhash because it's damn fast.
  cmdHash = xxhash.hash (new Buffer command), xxHashSeed
  'cmd' + cmdHash.toString 36
