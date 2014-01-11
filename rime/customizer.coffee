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

###
testCustomizer = ->
  c = new Config """
    abc:
      abcd: 1234
    def:
      defg: 5678
    """
  console.log c.toString()
  x = new Customizer
  x.patch 'abc/abcd', 4321
  x.patch 'def', null
  x.patch 'opq', true
  x.patch 'xyz', {uvw: 'rst'}
  console.log x.toString()
  x.applyPatch c
  console.log c.toString()

testCustomizer()
###
