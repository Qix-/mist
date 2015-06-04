 #
 #     _|      _|  _|              _|
 #     _|_|  _|_|        _|_|_|  _|_|_|_|
 #     _|  _|  _|  _|  _|_|        _|
 #     _|      _|  _|      _|_|    _|
 #     _|      _|  _|  _|_|_|        _|_|
 #
 #             MIST BUILD SYSTEM
 # Copyright (c) 2015 On Demand Solutions, inc.

module.exports.translate = (parsed)->
  result = []
  result.pushScoped = (val)-> @push "  #{val}"

  for statement in parsed
    switch statement.type
      when 'var' then result.push "#{statement.name}=#{statement.val}"
      else
        throw "Unknown Mistfile construct type: #{statement.type}"

  (result.join '\n') + '\n'
