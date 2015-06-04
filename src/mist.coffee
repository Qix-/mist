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
  console.log 'platform:', os.platform()
  switch os.platform()
    when 'darwin' or 'linux'
      console.log 'running Ninja'
      proc = spawn ninjaProc, [ '-vf', '/dev/stdin' ], stdio: [ null,
        process.stdout, process.stderr ]
      console.log 'uploading translated Mist configuration to Ninja...'
      proc.stdin.write ninja
      console.log 'upload complete'
      proc.stdin.end()
    else
      console.log 'streaming translated Mist configuration to disk...'
      tmpFile = tmp.fileSync()
      fs.writeSync tmpFile.fd, ninja
      console.log 'streaming complete'
      fs.closeSync tmpFile.fd
      console.log 'running Ninja'
      spawn ninjaProc, [ '-vf', tmpFile.name ], stdio: [ 'pipe',
        process.stdout, process.stderr ]

runNinja ''
