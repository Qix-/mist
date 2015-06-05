 #
 #     _|      _|  _|              _|
 #     _|_|  _|_|        _|_|_|  _|_|_|_|
 #     _|  _|  _|  _|  _|_|        _|
 #     _|      _|  _|      _|_|    _|
 #     _|      _|  _|  _|_|_|        _|_|
 #
 #             MIST BUILD SYSTEM
 # Copyright (c) 2015 On Demand Solutions, inc.

glob = require 'glob'
MistNinjaBuilder = require './mist-ninja-builder'

Array::unique = ->
  a = []
  i = 0
  l = @length
  while i < l
    if a.indexOf(@[i]) == -1
      a.push @[i]
    ++i
  return a

Array::flatten = ->
  @reduce (a, b)->
      a.concat (if b instanceof Array then b else [b])
    , []

globCache = {}
globStatCache = {}
globSymCache = {}

performGlob = (pattern, mistdir)->
  globOpts =
    cwd: mistdir
    root: mistdir # TODO change this to the root Mistfile dir
                  #      when nested Mistfiles are implemented
    dot: no       # NOTE: you can still search dotfiles by explicitely including
                  #       a dot
    nomount: no
    nosort: yes
    silent: yes
    strict: no
    cache: globCache
    statCache: globStatCache
    symlinks: globSymCache
    nounique: no
    nonull: no
    debug: no
    nobrace: no
    noglobstar: no
    noext: no
    nocase: no    # yes? can't decide
    matchBase: no # NOTE: forces explicit recursiveness
    nodir: yes
    follow: yes   # no? can't decide
    nonegate: yes # NOTE: negating globs is messy. stahp that.
    nocomment: yes

  if glob.hasMagic pattern
    glob.sync pattern, globOpts
  else
    [pattern]

doAllGlobs = (globs, mistdir) ->
  (performGlob pattern, mistdir for pattern in globs).flatten().unique()

module.exports.translate = (parsed, mistdir)->
  console.log '\n'   ##
  console.log parsed ## XXX DEBUG
  console.log '\n'   ##

  builder = new MistNinjaBuilder()
  builder.setRootDir mistdir # TODO must be executed only for the root file

  for statement in parsed
    switch statement.type
      when 'var'
        builder.setVar statement.name, statement.val
      when 'rule'
        try
          builder.addRuleHash statement.command
        catch e
          console.error "dup"

        # perform glob
        inFiles =
          main_inputs: doAllGlobs statement.main_inputs, mistdir
          dep_inputs: doAllGlobs statement.dep_inputs, mistdir
          order_inputs: doAllGlobs statement.order_inputs, mistdir
          main_outputs: statement.main_outputs.unique()
          aux_outputs: statement.aux_outputs.unique()

        # foreach?
        if statement.foreach then inFiles.main_inputs.join ' '

        # write build rule(s)

      else
        throw "Unknown Mistfile construct type: #{statement.type}"

  builder.render()
