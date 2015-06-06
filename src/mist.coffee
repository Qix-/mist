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
path = require 'path'
spawn = (require 'child_process').spawn
MistParser = require './mist-parser'
MistTranslator = require './mist-translator'

ninjaProc = process.env.NINJA || 'ninja'

runNinja = (ninja, base)->
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
      spawn ninjaProc,
        [ '-vf', tmpFile.name, '-C', base ],
          stdio: [ 'pipe',process.stdout, process.stderr ]

findMist = ()->
  curPath = process.cwd()
  lastPath = ''
  loop
    lastPath = curPath
    mistPath = path.join curPath, 'Mistfile'
    try
      stat = fs.statSync mistPath
      return mistPath if stat.isFile()
    break if (curPath = path.dirname curPath) is lastPath

  throw 'Mistfile not found (reached filesystem boundary)'

try
  mistfile = findMist()
  mistdir = path.dirname mistfile
  console.log 'evaporating Mistfile at', mistfile
  try
    contents = fs.readFileSync(mistfile).toString()
    result = MistParser.parse contents, mistdir:mistdir
  catch e
    throw e # XXX DEBUG

  console.log 'performing Mist->Ninja pass-off'
  console.log '\n'   ##
  console.log result ## XXX DEBUG
  console.log '\n'   ##
  runNinja result, mistdir
catch e
  throw e # XXX DEBUG
