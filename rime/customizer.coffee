exports.Customizer = class Customizer extends Config

  constructor: (yaml) ->
    super(yaml)
    @root ?= {}
    @root.patch ?= {}

  patch: (key, value) ->
    @root.patch[key] = value

  applyPatch: (config) ->
    for key, value of @root.patch
      config.set key, value
