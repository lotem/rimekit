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
    return false
  return true

exports.Recipe = class Recipe

  constructor: (@props) ->
    @validate()

  validate: ->
    throw Error('missing recipe name.') unless @props.name
    throw Error('missing recipe version.') unless @props.version
    unless /^[_0-9A-Za-z]+$/.test @props.name
      throw Error('recipe name should be alpha_numeric.')
    unless typeof @props.version is 'string'
      throw Error('recipe version should be string type.')
    # TODO

  installSchema: (schemaId, options) ->
    # TODO

  enableSchema: (schemaId, enabled = true) ->
    # TODO

  customize: (configId, proc) ->
    # TODO
