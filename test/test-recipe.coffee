rime = require '../app.nw/rime'

exports.testRecipeValidation = (test) ->
  test.throws (-> new rime.Recipe), Error, 'Should fail without required params.'
  test.doesNotThrow -> new rime.Recipe
    name: 'a_name'
    version: '1.0'
  test.done()

