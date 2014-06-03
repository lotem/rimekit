rime = require '../app.nw/rime'
fs = require 'fs'

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
  test.throws (-> new rime.Recipe
    name: 'a_name'
    version: '1.0'
    rimeUserDir: './nonexistent/path/3.1415926'
  ), Error, 'Should fail when missing rimeUserDir.'
  test.doesNotThrow (-> new rime.Recipe
    name: 'a_name'
    version: '1.0'
    rimeUserDir: '.'
  ), Error, 'Should pass recipe validation.'
  test.done()

exports.testParametrizedRecipe = (test) ->
  rime.recipes.autoSave = false
  recipe = new rime.Recipe
    name: 'a_name'
    version: '1.0'
    params: [
      {name: 'required_param', required: true}
    ]
  test.throws -> recipe.collectParams {}
  recipe = new rime.Recipe
    name: 'a_name'
    version: '1.0'
    params: [
      {name: 'required_param', required: true}
    ]
  test.doesNotThrow -> recipe.collectParams {required_param: 'value'}
  test.done()

exports.recipeCustomize =

  setUp: (callback) ->
    @recipe = new rime.Recipe
      name: 'test_recipe_customize'
      version: '1.0'
      rimeUserDir: 'test'
    @configPath = "#{@recipe.props.rimeUserDir}/#{@recipe.props.name}.custom.yaml"
    if fs.existsSync @configPath
      fs.unlinkSync @configPath
    callback()

  tearDown: (callback) ->
    if fs.existsSync @configPath
      fs.unlinkSync @configPath
    callback()

  testRecipeCustomize: (test) ->
    @recipe.customize @recipe.props.name, (c) ->
      test.ok c
      c.patch 'foo/bar', 'test'
    .then =>
      c = new rime.Config
      c.loadFile(@configPath).then ->
        test.equal c.get('patch')['foo/bar'], 'test'
    .catch (err) ->
      test.ifError err
    .then ->
      test.done()

###
exports.testRecipeDownload = (test) ->
  recipe = new rime.Recipe
    name: 'sample_recipes'
    version: '1.0'
    rimeUserDir: 'test'
    files: [
      'https://raw.github.com/lotem/rimekit/develop/sample/dungfungpuo.recipe.coffee'
      'https://raw.github.com/lotem/rimekit/develop/sample/horizontal_layout.recipe.coffee'
      'https://raw.github.com/lotem/rimekit/develop/sample/slash_symbols.recipe.coffee'
    ]
  recipe.downloadFiles()
  .then ->
    # TODO: check file integrity.
    true
  .catch (err) ->
    test.ifError err
  .then ->
    test.done()
###
