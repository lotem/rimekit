rime = require '../app.nw/rime'

exports.testCustomizer = (test) ->
  c = new rime.Config """
    abc:
      abcd: 1234
    def:
      defg: 5678
    """
  test.equal c.get('abc/abcd'), 1234
  test.equal c.get('def/defg'), 5678
  x = new rime.Customizer
  x.patch 'abc/abcd', 4321
  x.patch 'def', null
  x.patch 'opq', true
  x.patch 'xyz', {uvw: 'rst'}
  test.deepEqual x.root,
    patch:
      'abc/abcd': 4321
      'def': null
      'opq': true
      'xyz': {uvw: 'rst'}
  x.applyPatch c
  test.equal c.get('abc/abcd'), 4321
  test.equal c.get('def'), null
  test.equal c.get('def/defg'), null
  test.equal c.get('opq'), true
  test.equal c.get('xyz/uvw'), 'rst'
  test.done()
