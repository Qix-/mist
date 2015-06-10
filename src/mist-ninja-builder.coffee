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
    @reg =
      rules: {}
      vars: [
        ['ninja_required_version', '1.5.0']
        ['builddir', path.join @rootDir, '.mist']
      ]
      groups: {}
      targets: []

    @ninjaProc = "ninja"

  setNinjaProc: (@ninjaProc)->

  loadFile: (filename)->
    @load path.dirname(filename), (fs.readFileSync filename).toString()

  load: (dir, contents)->

  writeFile: (filename, options)->
    stream = fs.createWriteStream filename, options
    @write stream
    stream.close()

  write: (stream)->

  render: -> ''

  run: (exArgs = [], opts = (stdio:[null, process.stdout, process.stderr]),
      exitcb = process.exit)->
    rendered = @render()
    console.log @rootDir
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
