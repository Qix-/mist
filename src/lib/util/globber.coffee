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

globCache = {}
globStatCache = {}
globSymCache = {}

module.exports.performGlob = (pattern, mistdir)->
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
    nonull: yes   # NOTE: in the event no files are found, we should assume
                  #       it's a regular file name
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
