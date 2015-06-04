 #
 #     _|      _|  _|              _|
 #     _|_|  _|_|        _|_|_|  _|_|_|_|
 #     _|  _|  _|  _|  _|_|        _|
 #     _|      _|  _|      _|_|    _|
 #     _|      _|  _|  _|_|_|        _|_|
 #
 #             MIST BUILD SYSTEM
 # Copyright (c) 2015 On Demand Solutions, inc.

tmp = require 'tmp'
fs = require 'fs'
os = require 'os'
spawn = (require 'child_process').spawn
MistParser = require './mist-parser'

ninjaProc = process.env.NINJA || 'ninja'

runNinja = (ninja)->
  console.log 'running Ninja'
  console.log 'platform:', os.platform()
  switch os.platform()
    when 'darwin' or 'linux'
      stream = new (require 'stream').Readable
      proc = spawn ninjaProc, [ '-vf', '/dev/stdin' ], stdio: [ null,
        process.stdout, process.stderr ]
      proc.stdin.write ninja
      proc.stdin.end()
    else
      tmpFile = tmp.fileSync()
      fs.writeSync tmpFile.fd, ninja
      fs.closeSync tmpFile.fd
      spawn ninjaProc, [ '-vf', tmpFile.name ], stdio: [ 'pipe',
        process.stdout, process.stderr ]

runNinja ''
