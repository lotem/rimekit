rime = require '../app.nw/rime'
fs = require 'fs'

exports.testRecipeValidation = (test) ->
  test.throws (-> new rime.Recipe), Error, 'Should fail without required params.'
  test.throws (-> new rime.Recipe
    name: 'an-invalid-name'
    version: '1.0'
    rimeDirectory: '.'
  ), Error, 'Should fail for recipe name.'
  test.throws (-> new rime.Recipe
    name: 'a_name'
    version: 1.0
    rimeDirectory: '.'
  ), Error, 'Should fail for recipe version.'
  test.throws (-> new rime.Recipe
    name: 'a_name'
    version: '1.0'
  ), Error, 'Should fail for missing rimeDirectory.'
  test.doesNotThrow (-> new rime.Recipe
    name: 'a_name'
    version: '1.0'
    rimeDirectory: '.'
  ), Error, 'Should pass recipe validation.'
  test.done()

exports.testParametrizedRecipe = (test) ->
  recipe = new rime.Recipe
    name: 'a_name'
    version: '1.0'
    rimeDirectory: '.'
    params: [
      {name: 'required_param', required: true}
    ]
  test.throws -> rime.cook recipe
  recipe = new rime.Recipe
    name: 'a_name'
    version: '1.0'
    rimeDirectory: '.'
    params: [
      {name: 'required_param', required: true}
    ]
  test.doesNotThrow -> rime.cook recipe, {required_param: 'value'}
  test.done()

exports.recipeCustomize =

  setUp: (callback) ->
    @recipe = new rime.Recipe
      name: 'test_recipe_customize'
      version: '1.0'
      rimeDirectory: 'test'
    @configPath = "#{@recipe.props.rimeDirectory}/#{@recipe.props.name}.custom.yaml"
    if fs.existsSync @configPath
      fs.unlinkSync @configPath
    callback()

  tearDown: (callback) ->
    if fs.existsSync @configPath
      fs.unlinkSync @configPath
    callback()

  testRecipeCustomize: (test) ->
    done = (err) =>
      test.ifError err
      c = new rime.Config
      c.loadFile @configPath, (c) ->
        test.ok c
        test.equal c.get('patch')['foo/bar'], 'test'
        test.done()
    @recipe.customize @recipe.props.name, done, (c) ->
      test.ok c
      c.patch 'foo/bar', 'test'

exports.testRecipeDownload = (test) ->
  recipe = new rime.Recipe
    name: 'test_download'
    version: '1.0'
    rimeDirectory: 'test'
    files: [
      'https://raw.github.com/lotem/brise/master/supplement/ipa_xsampa.schema.yaml'
      'https://raw.github.com/lotem/brise/master/supplement/ipa_xsampa.dict.yaml'
    ]
  recipe.downloadFiles (err) ->
    test.ifError err
    test.done()
