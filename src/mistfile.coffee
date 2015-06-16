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

MistInput = require './mist-input'

module.exports = class Mistfile
  constructor: (@vars = {})->
    @mounts = []

    # Reference arrays must not be re-assigned. They're referenced by
    # rules. For instance, the resolver uses the globs by popping the
    # first element as the glob string and then pushing back the results.
    @refs =
      globs: {}
      groups: {}
      commands: {}

    @rules = []

  ###
  # Gets the array reference to the given glob
  #
  # glob:
  #   The glob string
  ###
  getGlobRef: (glob)->
    if glob not of @refs.globs
      @refs.globs[glob] = []
    return @refs.globs[glob]

  ###
  # Gets the array reference to the given glob
  #
  # glob:
  #   The glob string
  ###
  getGroupRef: (group)->
    if group not of @refs.groups
      @refs.groups[group] = []
    return @refs.groups[group]

  ###
  # Gets the command reference to the given command
  #
  # command:
  #   The command string
  ###
  getCommandRef: (command)->
    if command not of @refs.commands
      @refs.commands[command] =
        command: command
        hash: Hasher.hash command
        vars: {}
    return @refs.commands[command]

  ###
  # Abstract reference retriever
  #
  # obj:
  #   An object:
  #   {type:String, value:String}
  ###
  getRef: (obj)->
    switch obj.type
      when 'glob' then @getGlobRef obj.value
      when 'group' then @getGroupRef obj.value
      else
        throw "unknown ref type: #{obj.type}"

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
    @vars[name] = val.replace /\$\$\(\s*?([a-z0-9_]+)\s*\)/gi, (m, name)->
      "$(#{name})"

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
    str = str.replace /(?:(?!\$).)\$\(\s*?([a-z0-9_]+)\s*\)/gi, (m, name)=>
      @expand @get name

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

    @rules.push ref = {}

    # resolve refs
    # this also, in turn, expands the input strings
    ref.command = @getCommandRef @expand rule.command
    ref.inputs = @getRef @expand i for i in rule.inputs || []
    ref.dependencies = @getRef @expand i for i in rule.inputs || []
    ref.orderDependencies = @getRef @expand i for i in rule.orderDependencies || []
    ref.outputs = @expand i for i in rule.outputs || []
    ref.auxOutputs = @expand i for i in rule.auxOutputs || []
    ref.groups = @getGroupRef @expand i for i in rule.groups || []
    ref.foreach = !!rule.foreach

  ###
  # Creates a new resolver for this mistfile.
  #
  # Should only be called on the root-most Mistfile.
  #
  # root:
  #   Absolute path for this mistfile (the folder to resolve against)
  ###
  resolve: (root)->
    new MistResolver root, @

  ###
  # Mount another Mistfile at a specific relative path
  #
  # mist
  #   The Mistfile object to mount
  # path
  #   The path relative to this file for where the Mistfile is
  #   (for resolution)
  ###
  mount: (mist, path)->
    @mounts.push
      mist: mist
      path: path
