 #
 #     _|      _|  _|              _|
 #     _|_|  _|_|        _|_|_|  _|_|_|_|
 #     _|  _|  _|  _|  _|_|        _|
 #     _|      _|  _|      _|_|    _|
 #     _|      _|  _|  _|_|_|        _|_|
 #
 #             MIST BUILD SYSTEM
 # Copyright (c) 2015 On Demand Solutions, inc.

path = require 'path'
xxhash = require 'xxhash'
MistGlobber = require './mist-globber'

xxHashSeed = (parseInt 'AEROMIST', 30) >> 2

module.exports = class MistNinjaBuilder
  constructor: (@registry = {})->
    @rootDir
    @registry.vars = @registry.vars || []
    @registry.rules = @registry.rules || {}
    @registry.targets = @registry.targets || []

    @commandDict = @compileCommandDict()
    @commandDictRefs = {}
    for k, v of @commandDict
      @commandDictRefs[k] = ["${#{v[0]}}"]

  setRootDir: (@rootDir)->
  setDir: (@mistDir)->

  setVar: (name, val)->
    @registry.vars.push name:name, val:val

  getVar: (name)->
    for pair in @registry.vars
      return pair.val if pair.name is name

  delimitDict: (str, dict)->
    # note that lib object values should all be arrays of equal length!
    # it is a pre-req and this method does not check for it.
    results = []
    for k, p of dict
      if not p.length
        results = [str]
        break
      for v, i in p
        results[i] = (results[i] || str).replace new RegExp("%#{k}", 'g'), v
    return results

  compileDict: (inputs)->
    dict = {}
    dict.f = inputs
    dict.b = inputs.map path.basename
    dict.B = dict.b.map (s)-> s.replace /^([^.]+).+$/, '$1'
    return dict

  compileCommandDict: ->
    dict = {}
    for c in "ofbB"
      dict[c] = ["D_#{c}"]
    return dict

  delimitCommand: (cmd)->
    (@delimitDict cmd, @commandDictRefs)[0]

  delimitAll: (arr, dict = {})->
    arr
      .map (v)=> @delimitDict v, dict
      .flatten()

  addRule: (name, command, vars = {})->
    if @registry.rules[name]?
      throw "attempt to add duplicate rule '#{name}'"
    @registry.rules[name] = rule = command:command
    for k,v of vars
      rule[k] = v

  addRuleHash: (command, vars = {})->
    hash = MistNinjaBuilder.hashCommand command
    @addRule hash, command, vars

  addTarget: (statement)->
    command = @delimitCommand statement.command
    commandHash = MistNinjaBuilder.hashCommand command

    # add the rule
    try
      @addRule commandHash, command
      # we silently ignore duplicates

    targets = []


    if statement.main_inputs.length
      statement.main_inputs =
        MistGlobber.doAllGlobs statement.main_inputs, @mistDir
      # TODO error on no inputs (but only if globs were supplied)

    if statement.foreach
      for inp in statement.main_inputs
        targets.push
          main_inputs: [inp]
          dep_inputs: statement.dep_inputs.slice 0
          order_inputs: statement.order_inputs.slice 0
          main_outputs: statement.main_outputs.slice 0
          aux_outputs: statement.aux_outputs.slice 0
    else
      targets = [statement]

    targets.forEach (target)=>
      target.rule = commandHash

      build_vars = @compileDict target.main_inputs
      console.log "\x1b[31m", build_vars, "\x1b[0m"

      target.dep_inputs =
        @delimitAll target.dep_inputs, build_vars
      target.order_inputs =
        @delimitAll target.order_inputs, build_vars

      target.dep_inputs =
        MistGlobber.doAllGlobs target.dep_inputs, @mistDir
      target.order_inputs =
        MistGlobber.doAllGlobs target.order_inputs, @mistDir


      target.main_outputs =
        @delimitAll target.main_outputs, build_vars
      target.aux_outputs =
        @delimitAll target.aux_outputs, build_vars

      target.main_outputs =
        target.main_outputs.unique()
      target.aux_outputs =
        target.aux_outputs.unique()

      target.build_vars = {}
      for k, d of @commandDict
        switch k
          when 'o' then target.build_vars[d] = target.main_outputs
          else target.build_vars[d] = build_vars[k]

        target.build_vars[d] = target.build_vars[d].join ' '

      target.main_inputs = target.main_inputs.join ' '
      target.dep_inputs = target.dep_inputs.join ' '
      target.order_inputs = target.order_inputs.join ' '
      target.main_outputs = target.main_outputs.join ' '
      target.aux_outputs = target.aux_outputs.join ' '

      @registry.targets.push target

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
      outputs = target.main_outputs + target.aux_outputs
      lines.push "build #{outputs}: " +
           "#{target.rule} " +
           "#{target.main_inputs}" +
           "#{if target.dep_inputs then " | #{target.dep_inputs}" else ''}" +
           "#{if target.order_inputs then " || #{target.order_inputs}" else ''}"
      for k, v of target.build_vars
        lines.pushScoped "#{k}=#{v}"

    lines.push '' # Ninja requires a newline at the end :)
    console.log lines.join '\n'
    lines.join '\n'

MistNinjaBuilder.hashCommand = (command)->
  # we use xxhash because it's damn fast.
  cmdHash = xxhash.hash (new Buffer command), xxHashSeed
  'cmd' + cmdHash.toString 36
