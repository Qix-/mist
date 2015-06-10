 #
 #     _|      _|  _|              _|
 #     _|_|  _|_|        _|_|_|  _|_|_|_|
 #     _|  _|  _|  _|  _|_|        _|
 #     _|      _|  _|      _|_|    _|
 #     _|      _|  _|  _|_|_|        _|_|
 #
 #             MIST BUILD SYSTEM
 # Copyright (c) 2015 On Demand Solutions, inc.

module.exports.install = ->
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

  Array::compile = ->
    @flatten().unique()

  Array::pushAll = (arrs...)->
    for arr in arrs
      if arr instanceof Array
        Array::push.apply @, arr
      else
        @push arr

  Array::linearize = ->
    @compile().join ' '

  String::applyDictionary = (regex, dict)->
    @replace regex, (m, name)-> dict[name] || m
