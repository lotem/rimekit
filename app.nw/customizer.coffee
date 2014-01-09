class Customizer extends Config

  addPatch: (key, value) ->
    @root ?= {}
    @root.patch ?= {}
    @root.patch[key] = value

  applyPatch: (config) ->
    for key, value of @root.patch
      config.set key, value
