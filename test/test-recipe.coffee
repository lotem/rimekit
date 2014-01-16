rime = require '../app.nw/rime'

exports.testRecipeValidation = (test) ->
  test.throws (-> new rime.Recipe), Error, 'Should fail without required params.'
  test.throws (-> new rime.Recipe
    name: 'an-invalid-name'
    version: '1.0'
  ), Error, 'Should fail for recipe name.'
  test.throws (-> new rime.Recipe
    name: 'a_name'
    version: 1.0
  ), Error, 'Should fail for recipe version.'
  test.doesNotThrow (-> new rime.Recipe
    name: 'a_name'
    version: '1.0'
  ), Error, 'Should pass recipe validation.'
  test.done()

exports.testParametrizedRecipe = (test) ->
  recipe = new rime.Recipe
    name: 'a_name'
    version: '1.0'
    params: [
      {name: 'required_param', required: true}
    ]
  test.throws -> rime.cook recipe
  recipe = new rime.Recipe
    name: 'a_name'
    version: '1.0'
    params: [
      {name: 'required_param', required: true}
    ]
  test.doesNotThrow -> rime.cook recipe, {required_param: 'value'}
  test.done()
