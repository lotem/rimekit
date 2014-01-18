exports.cook = cook = (recipe, ingredients, callback) ->
  if not callback? and typeof ingredients is 'function'  # (recipe, callback)
    [ingredients, callback] = [null, ingredients]
  # if no callback is given, throw errors
  callback ?= (err) -> throw err if err
  try
    unless recipe instanceof Recipe  # cook {...}, ...
      recipe = new Recipe recipe
    if recipe.props.params
      recipe.collectParams(ingredients)
  catch e
    console.error "error cooking recipe: #{e}"
    callback e
    return
  finish = (err) ->
    if (err)
      callback err
      return
    if recipe.props.setup
      try
        recipe.props.setup.call recipe
      catch e
        console.error "error cooking recipe: #{e}"
        callback e
        return
    callback()
  if recipe.props.files
    recipe.downloadFiles finish
  else  # no files needed to download
    finish()


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

  collectParams: (ingredients) ->
    for param in @props.params
      unless param and typeof param is 'object'
        throw Error('invalid parameter definition.')
      if param.required and not ingredients?[param.name]?
        throw Error("missing ingredient: #{param.name}")
    # TODO

  downloadFiles: (callback) ->
    # TODO
    callback()

  installSchema: (schemaId, options) ->
    # TODO

  enableSchema: (schemaId, enabled = true) ->
    # TODO

  customize: (configId, proc) ->
    # TODO
