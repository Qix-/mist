#
#     _|      _|  _|              _|
#     _|_|  _|_|        _|_|_|  _|_|_|_|
#     _|  _|  _|  _|  _|_|        _|
#     _|      _|  _|      _|_|    _|
#     _|      _|  _|  _|_|_|        _|_|
#
#             MIST BUILD SYSTEM
# Copyright (c) 2015 On Demand Solutions, inc.

# This class has a few moving parts. First, you set up
# the target configuration tree via the MistNinja class.
#
# From there, you perform a resolution. Resolution occurs
# by taking all paths and mounts and resolving the path
# to them.

(require './utils').install()

fs = require 'fs'
path = require 'path'
MistResolver = require './mist-resolver'
MistParser = require './mist-parser'

module.exports = class Mistfile
  constructor: (@vars = {})->
    @rules = []

  ###
  # Sets a parse variable
  #
  # name:
  #   The name of the variable to set
  # val:
  #   The new value
  ###
  set: (name, val)->
    val = @expand val
    @vars[name] = val

  ###
  # Gets a parse variable's value
  #
  # name:
  #   The name of the variable to get
  ###
  get: (name)->
    @vars[name] || ''

  ###
  # Unsets a variable
  #
  # name:
  #   The name of the variable to unset
  ###
  unset: (name)->
    delete @vars[name]

  ###
  # Expands a string using the currently configured parse variables
  ###
  expand: (str)->
    if typeof str is 'string'
      return str.replace /(?:(?!\$).)\$\(\s*?([a-z0-9_]+)\s*\)/gi, (m, name)=>
        @expand @get name
    else if str.type? and str.value?
      return type: str.type, value: @expand str.value

  ###
  # Adds a rule given inputs and outputs and a command
  #
  # rule: Object
  #   command:
  #     The command to run for the inputs/outputs
  #   inputs:
  #     The inputs to process
  #     [{type:String, value:String}]
  #   dependencies:
  #     The dependencies to add
  #     [{type:String, value:String}]
  #   orderDependencies:
  #     The order dependencies to add
  #     [{type:String, value:String}]
  #   outputs:
  #     The outputs to add
  #   auxOutputs:
  #     The auxiliary outputs to add
  #   groups:
  #     The groups to feed to
  #   foreach:
  #     Whether or not to split each resolved input into its own target
  ###
  addRule: (rule = {})->
    if not rule.command?
      throw 'rules must have a command'

    @rules.push ref = src: {}, targets: {}

    console.log "\x1b[32m", rule, "\x1b[0m"
    # copy rule as a source 'template'
    ref.src.command = rule.command
    ref.src.inputs = (rule.inputs || []).slice 0
    ref.src.dependencies = (rule.dependencies || []).slice 0
    ref.src.orderDependencies = (rule.orderDependencies || []).slice 0
    ref.src.outputs = (rule.outputs || []).slice 0
    ref.src.auxOutputs = (rule.auxOutputs || []).slice 0
    ref.src.groups = (rule.groups || []).slice 0
    ref.src.foreach = !!rule.foreach

  ###
  # Creates a new resolver for this mistfile.
  #
  # Should only be called on the root-most Mistfile.
  #
  # root:
  #   Absolute path for this mistfile (the folder to resolve against)
  # resolver:
  #   The resolver to use
  ###
  resolve: (root, resolver = MistResolver)->
    new resolver root, @

###
# Looks for a mist file in the given directory or its parents
#
# from:
#   The path from which to look for a Mistfile (traverses upward)
###
Mistfile.find = (from = process.cwd())->
  lastPath = ''
  loop
    lastPath = from
    mistPath = path.join from, 'Mistfile'
    try
      stat = fs.statSync mistPath
      return mistPath if stat.isFile()
    break if (from = path.dirname from) is lastPath
  return null

###
# Reads a file in and parses it as Mistfile syntax, returning a
# new Mistfile object
#
# filename:
#   The path of the file to read
# vars:
#   Initial parse variables to use when parsing
###
Mistfile.fromFile = (filename, vars = {})->
  Mistfile.fromString fs.readFileSync(filename), vars

###
# Parses a string as Mistfile syntax, returning a new Mistfile object
#
# str:
#   The string contents to parse
# vars:
#   Initial parse variables to use when parsing
###
Mistfile.fromString = (str, vars = {})->
  options =
    mist: new Mistfile vars
  MistParser.parse str.toString(), options
  return options.mist
