YAML = require('yamljs')

class Config
  constructor: (yaml) ->
    @root = if yaml then YAML.parse yaml else null

  loadFile: (filePath) ->
    @root = YAML.load filePath

  toString: ->
    YAML.stringify(@root)

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
