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
  test.ok !rime.cook new rime.Recipe(
    name: 'a_name'
    version: '1.0'
    params: [
      {name: 'a_param', required: true}
    ]
  ), {}
  test.ok rime.cook new rime.Recipe(
    name: 'a_name'
    version: '1.0'
    params: [
      {name: 'a_param', required: true}
    ]
  ), {
    a_param: 'ingredient'
  }
  test.done()
