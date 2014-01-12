exports.cook = cook = (recipe) ->
  unless recipe instanceof Recipe
    recipe = new Recipe recipe
  try
    if recipe.props.files
      recipe.downloadFiles()
    if recipe.props.params
      recipe.collectParams()
    recipe.props.setup.call recipe
  catch e
    console.error 'error cooking recipe: ' + e

exports.Recipe = class Recipe

  constructor: (@props) ->
    @validate()

  validate: ->
    # TODO

  installSchema: (schemaId, options) ->
    # TODO

  enableSchema: (schemaId, enabled = true) ->
    # TODO

  customize: (configId, proc) ->
    # TODO
