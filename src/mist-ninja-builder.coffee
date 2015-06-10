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
xxhash = require 'xxhash'
MistParser = require './mist-parser'
MistGlobber = require './mist-globber'

(require './utils').install()
xxHashSeed = (parseInt 'AEROMIST', 30) >> 2

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
      emit: (statement)=>
        if statement instanceof Array
          statement.forEach (s)-> s.cwd = dir
        else
          statement.cwd = dir
        @emit statement

  writeFile: (filename, options)->
    stream = fs.createWriteStream filename, options
    @write stream
    stream.close()

  write: (stream)->
    rendered = @render()
    steam.write rendered

  inlineVariables: (str, vars)->
    str.replace /\$\(\s*([a-z_][a-z0-9_]*)\s*\)/gi,
      (m, name)-> vars[name] || ''

  prepareCommand: (command)->
    command.replace /\%([fo])/g, '${_$1}'

  compile: ->
    result = []

    vars = {} # NOTE: When sub-mist file processing is added, make a new
              #       MistNinjaBuilder with these vars already added and
              #       compile the result. In theory that should work.
    rules = {}

    for statement in @reg
      switch statement.type
        when 'var'
          vars[statement.name] = statement.value
        when 'target'
          target = {}
          for k, v of statement
            target[k] = v

          targets = {}

          if target.command not of rules
            commandHash = MistNinjaBuilder::hashCommand target.command
            rules[target.command] = commandHash
            result.push
              type: 'rule'
              name: commandHash
              command: @prepareCommand target.command
          else
            commandHash = rules[command]

          console.log '\x1b[31m', target, '\x1b[0m'
          aggInputs = []
          for input in target.mainInputs
            switch input.type
              when 'glob'
                input = @inlineVariables input.glob, vars
                aggInputs.push MistGlobber.performGlob input, @rootDir
              when 'group'
                console.warn 'WARN: groups not yet implemented'
              else
                throw "unknown input type: #{input.type}\n" +
                  "  at #{@rootDir}/Mistfile:#{target.line}:#{target.column}"
            if input of targets
              throw "duplicate input: #{input}\n" +
                "  at #{@rootDir}/Mistfile:#{target.line}:#{target.column}"

          targets = aggInputs.compile().map (input)=>
            # NOTE: do not flatten arrays here!
            #       things like groups rely on array references
            #       to forward populate!
            type: 'target'
            command: commandHash
            mainInputs: [input]
            # TODO

          if not target.foreach
            reduceFn = (prev, cur)=>
              return cur if not prev

              console.log '\x1b[32m', prev, '\x1b[0m'
              prev.mainInputs.pushAll cur.mainInputs
              return prev

            aggr = targets.reduce reduceFn, null
            targets = if aggr then [aggr] else []

          result.pushAll targets

        else
          throw "unknown statement type: #{statement.type}"
    return result

  render: ->
    compiled = @compile()
    console.log "\x1b[34m", compiled, "\x1b[0m"
    ''

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

MistNinjaBuilder::hashCommand = (command)->
  cmdHash = xxhash.hash (new Buffer command), xxHashSeed
  'cmd' + cmdHash.toString 36
