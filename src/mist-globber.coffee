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

module.exports.performGlob = (pattern, mistdir)->
  console.log "\x1b[31m",mistdir,"\x1b[0m"
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

  glob.sync pattern, globOpts

module.exports.doAllGlobs = (globs, mistdir)->
  (module.exports.performGlob pattern, mistdir for pattern in globs)
    .flatten()
    .unique()

