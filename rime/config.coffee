jsyaml = require 'js-yaml'

exports.Config = class Config
  constructor: (yaml) ->
    @root = if yaml then jsyaml.safeLoad yaml else null

  loadFile: (filePath, callback) ->
    fs.readFile filePath, {encoding: 'utf8'}, (err, data) =>
      if err
        console.error "error loading config: #{err}"
        callback null
      else
        try
          @root = jsyaml.safeLoad data, filename: filePath
        catch err
          console.error "error loading config: #{err}"
          callback null
          return
        callback @

  saveFile: (filePath, callback) ->
    fs.writeFile filePath, @toString(), callback

  toString: ->
    jsyaml.safeDump @root, flowLevel: 3

  get: (key) ->
    ks = (x for x in key.split '/' when x)
    if ks.length == 0  # '', '/'
      return @root
    node = @root
    for k in ks
      break unless node?
      node = node[k]
    node

  set: (key, value) ->
    ks = (x for x in key.split '/' when x)
    if ks.length == 0  # '', '/'
      return @root = value
    @root ?= {}
    node = @root
    kend = ks.pop()
    for k in ks
      node[k] = {} unless node[k]?
      node = node[k]
    node[kend] = value
