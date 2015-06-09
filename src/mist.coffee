 #
 #     _|      _|  _|              _|
 #     _|_|  _|_|        _|_|_|  _|_|_|_|
 #     _|  _|  _|  _|  _|_|        _|
 #     _|      _|  _|      _|_|    _|
 #     _|      _|  _|  _|_|_|        _|_|
 #
 #             MIST BUILD SYSTEM
 # Copyright (c) 2015 On Demand Solutions, inc.

try
  (require 'source-map-support').install()
tmp = require 'tmp'
fs = require 'fs'
os = require 'os'
path = require 'path'
spawn = (require 'child_process').spawn
config = require 'commander'
packageJson = require '../package'
MistParser = require './mist-parser'

ninjaProc = process.env.NINJA || "#{__dirname}/ninja/ninja"

ninjaArgs = []
mistArgs = []
for a, i in process.argv.slice 2
  if a is '--'
    ninjaArgs = process.argv.slice i+3
    break
  else mistArgs.push a

config
  .version packageJson.version
  .parse mistArgs

runNinja = (ninja, base)->
  console.log 'platform:', os.platform()
  switch os.platform()
    when 'darwin' or 'linux'
      console.log 'running Ninja'
      proc = spawn ninjaProc, ([ '-vf', '/dev/stdin', '-C', base ]
        .concat ninjaArgs),
        stdio: [ null,
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
      proc = spawn ninjaProc,
        ([ '-vf', tmpFile.name, '-C', base ].concat ninjaArgs),
          stdio: [ 'pipe',process.stdout, process.stderr ]

  proc.on 'exit', process.exit

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
  runNinja result, mistdir
catch e
  throw e # XXX DEBUG
