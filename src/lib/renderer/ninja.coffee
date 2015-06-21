 #
 #     _|      _|  _|              _|
 #     _|_|  _|_|        _|_|_|  _|_|_|_|
 #     _|  _|  _|  _|  _|_|        _|
 #     _|      _|  _|      _|_|    _|
 #     _|      _|  _|  _|_|_|        _|_|
 #
 #             MIST BUILD SYSTEM
 # Copyright (c) 2015 On Demand Solutions, inc.

###
# Renders a resolver to a Ninja build file
#
# resolver:
#   A resolver, generated from a Mistfile
###

path = require 'path'
os = require 'os'
tmp = require 'tmp'
fs = require 'fs'
spawn = (require 'child_process').spawn

module.exports.render = (resolver)->
  targets = resolver.compile()

  out = [
    "ninja_required_version = 1.2"
    "builddir = #{path.join resolver.rootDir, '.mist'}"
  ]
  out.push2 = (s)-> @push "  #{s}"

  for name, vars of targets.commands
    out.push "rule #{name}"
    for k, v of vars
      out.push2 "#{k} = #{v}"

  for target in targets.targets
    out.push [
      'build'
      target.outputs
      if target.auxOutputs.length then '|' else ''
      target.auxOutputs
      ':'
      target.command.name
      target.inputs
      if target.dependencies.length then '|' else ''
      target.dependencies
      if target.orderDependencies.length then '||' else ''
      target.orderDependencies
    ].flatten().linearize()

    for k, v of target.command.vars
      out.push2 "#{k} = #{v}"

  out.push '' # Ninja requires a final newline.
  out.join '\n'

module.exports.run = (resolver, exArgs = [],
      proc = 'ninja',
      opts = (stdio:[null, process.stdout, process.stderr]),
      exitcb = process.exit)->

  rendered = module.exports.render resolver

  args = ['-v', '-w', 'dupbuild=err', '-C', resolver.rootDir]

  switch os.platform()
    when 'darwin' or 'linux'
      args.push '-f', '/dev/stdin'
      cb = (proc)->
        proc.stdin.write rendered
        proc.stdin.end()
    else
      tmpFile = tmp.fileSync()
      args.push '-f', tmpFile.name
      fs.writeSync tmpFile.fd, rendered
      fs.closeSync tmpFile.fd

  proc = spawn proc, args.concat(exArgs), opts
  proc.on 'exit', exitcb if exitcb
  cb proc if cb
