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
fs = require 'fs'
tmp = require 'tmp'
os = require 'os'
spawn = (require 'child_process').spawn
MistParser = require './mist-parser'

(require './array-utils').install()

module.exports = class MistNinjaBuilder
  constructor: (@rootDir = process.cwd())->
    @reg = [
      type: 'var', name: 'ninja_required_version', value: '1.5.0'
      type: 'var', name: 'builddir', value: path.join @rootDir, '.mist'
    ]

    @ninjaProc = "ninja"

  setNinjaProc: (@ninjaProc)->

  loadFile: (filename)->
    @load path.dirname(filename), (fs.readFileSync filename).toString()

  load: (dir, contents)->
    MistParser.parse contents,
      mist: @

  writeFile: (filename, options)->
    stream = fs.createWriteStream filename, options
    @write stream
    stream.close()

  write: (stream)->
    rendered = @render()
    steam.write rendered

  render: -> ''

  run: (exArgs = [], opts = (stdio:[null, process.stdout, process.stderr]),
      exitcb = process.exit)->
    rendered = @render()
    args = ['-v', '-C', @rootDir]

    switch os.platform()
      when 'darwin' or 'linux'
        args.push '-f', '/dev/stdin'
        cb = (proc)->
          proc.stdin.write rendered
          proc.stdin.end()
      else
        tmpFile = tmp.fileSync()
        args.push '-f', tmpFile.name
        fs.writeSync tmpFile.fd rendered
        fs.closeSync tmpFile.fd

    proc = spawn @ninjaProc, args, opts
    proc.on 'exit', exitcb if exitcb
    cb proc if cb

  emit: (statement)->
    if statement instanceof Array
      Array::push.apply @reg, statement
    else
      @reg.push statement

MistNinjaBuilder::findMistfile = (from = process.cwd())->
  lastPath = ''

  loop
    lastPath = from
    mistPath = path.join from, 'Mistfile'
    try
      stat = fs.statSync mistPath
      return mistPath if stat.isFile()
    break if (from = path.dirname from) is lastPath

  return null
