fs = require 'fs'
http = require 'http'
url = require 'url'

# recipe: Recipe or {...}
# ingredients: {...}
# callback: (err) ->
exports.cook = cook = (recipe, ingredients, callback) ->
  # if no callback is given, throw errors
  callback ?= (err) -> throw err if err
  try
    unless recipe instanceof Recipe  # cook {...}, ...
      recipe = new Recipe recipe
    if recipe.props.params
      recipe.collectParams(ingredients ? {})
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
        recipe.props.setup.call recipe, callback
      catch e
        console.error "error cooking recipe: #{e}"
        callback e
        return
  recipe.downloadFiles finish

exports.Recipe = class Recipe

  constructor: (@props) ->
    @validate()

  validate: ->
    # name and version are required
    throw Error('missing recipe name.') unless @props.name
    throw Error('missing recipe version.') unless @props.version
    unless /^[_0-9A-Za-z]+$/.test @props.name
      throw Error('recipe name should be alpha_numeric.')
    unless typeof @props.version is 'string'
      throw Error('recipe version should be string type.')
    # rime directory
    unless @props.rimeDirectory and fs.existsSync @props.rimeDirectory
      throw Error('Rime directory not accessible.')

  collectParams: (ingredients) ->
    for param in @props.params
      unless param and typeof param is 'object'
        throw Error('invalid parameter definition.')
      if param.required and not ingredients[param.name]?
        throw Error("missing ingredient: #{param.name}")
    # TODO

  # callback: (err) ->
  downloadFiles: (callback) ->
    unless @props.files  # no files needed to download
      callback()
      return
    # TODO:
    download_dir = 'download/'
    total = @props.files.length
    success = failure = 0
    finish = ->
      return unless success + failure == total
      if failure
        callback(new Error "failed to download #{failure}/#{total} files.")
      else
        callback()
    for file_url in @props.files
      file_name = url.parse(file_url).pathname.split('/').pop()
      http.get(file_url, (res) ->
        console.log "got response: #{res.statusCode}"
        file = fs.createWriteStream(download_dir + file_name)
        res.on 'data', (data) ->
          file.write data
        res.on 'end', ->
          file.end()
          console.log "#{file_name} downloaded to #{download_dir}"
          ++success
          finish()
      ).on 'error', (e) ->
        console.log "got error #{e.message}"
        ++failure
        finish()

  # callback: (err) ->
  installSchema: (schemaId, callback) ->
    # TODO

  # callback: (err) ->
  enableSchema: (schemaId, callback) ->
    # TODO

  # callback: (err) ->
  disableSchema: (schemaId, callback) ->
    # TODO

  # callback: (err) ->
  # proc: (customizer) ->
  customize: (configId, callback, proc) ->
    configPath = "#{@props.rimeDirectory}/#{configId}.custom.yaml"
    c = new Customizer
    finish = (c) ->
      proc c
      c.saveFile configPath, (err) -> callback err
    fs.exists configPath, (exists) ->
      if exists
        c.loadFile configPath, finish
      else
        finish c
