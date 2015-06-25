 #
 #     _|      _|  _|              _|
 #     _|_|  _|_|        _|_|_|  _|_|_|_|
 #     _|  _|  _|  _|  _|_|        _|
 #     _|      _|  _|      _|_|    _|
 #     _|      _|  _|  _|_|_|        _|_|
 #
 #             MIST BUILD SYSTEM
 # Copyright (c) 2015 On Demand Solutions, inc.

chalk = require 'chalk'
fs = require 'fs'

col = [
  "\x1b[0G"
  "\x1b[2G"
  "\x1b[13G"
  "\x1b[26G"
]

paragraph = (lines...)-> lines.filter((a)->a?).join '\n'
line = (args...)->
  l = args.filter((a)->a?).join ''
  l if l and l.length

compileExpected = (expected)->
  first = yes
  results = for e in expected.filter((i)->i.type isnt 'other')
    l = [
      if first
        first = no
        "#{col[1]}expected#{col[2]}"
      else
        "#{col[1]}or#{col[2]}"
      chalk.cyan.bold(e.description),
      col[3]
      if e.type then " #{chalk.dim.grey(e.type)}"
      if e.value then " #{chalk.dim.grey(e.value)}"
    ].filter((a)->a?).join ''
    l if l and l.length
  results.join '\n'

compileFileMarker = (filename, line, column)->
  try
    compileSourceMarker fs.readFileSync(filename).toString(), line, column
compileSourceMarker = (src, line, column)->
  lines = src.split /\r?\n/g
  line = lines[line-1]
  return if not (line and line.length)

  result = ['\n', line]
  if column
    c = column - 2
    d = if c < 0
        c = Math.abs c
        'D'
      else
        'C'
    result.push "\x1b[#{c}#{d}#{chalk.red.bold('^')}"

  result.join "\n#{col[1]}"

module.exports = (e)->
  if e.constructor is String then e = message:e
  if e.line? and e.map?
    e.line = e.map[e.line]

  console.error paragraph null,
    line '\n',
      chalk.red.bold('ERROR: '),
      e.message || 'unexpected error'

    line null,
      if e.filename or e.line then "#{col[1]}at#{col[2]}"
      if e.filename or e.line then e.filename || '[unknown]'
      if e.line then ":#{e.line}"
      if e.line and e.column then ":#{e.column}"

    line null,
      # peg error
      if e.expected then compileExpected e.expected

    line null
      # line/col resolution
      if e.source and e.line then compileSourceMarker e.source, e.line, e.column
      else if e.filename and e.line then compileFileMarker e.filename, e.line,
        e.column

  process.exit 10
