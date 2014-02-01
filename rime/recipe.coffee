fs = require 'fs'
path = require 'path'
request = require 'request'
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
    else
      callback()
  recipe.downloadFiles finish

exports.Recipe = class Recipe

  @rimeUserDir: '.'

  @rimeSharedDir: '.'

  constructor: (@props) ->
    @validate()

  validate: ->
    # name and version are required
    throw Error 'missing recipe name.' unless @props.name
    throw Error 'missing recipe version.' unless @props.version
    unless /^[_0-9A-Za-z]+$/.test @props.name
      throw Error 'recipe name should be alpha_numeric.'
    unless typeof @props.version is 'string'
      throw Error 'recipe version should be string type.'
    @rimeUserDir = @props.rimeUserDir ? Recipe.rimeUserDir
    unless @rimeUserDir and fs.existsSync @rimeUserDir
      throw Error 'Rime user directory not accessible.'
    @rimeSharedDir = @props.rimeSharedDir ? Recipe.rimeSharedDir

  collectParams: (ingredients) ->
    @params ?= {}
    for param in @props.params
      unless param and typeof param is 'object'
        throw Error('invalid parameter definition.')
      name = param.name
      if param.required and not ingredients[name]?
        throw Error("missing ingredient: #{name}")
      @params[name] = ingredients[name]
    # TODO save parameters

  # callback: (err) ->
  downloadFiles: (callback) ->
    unless @props.files  # no files needed to download
      callback()
      return
    download = "#{@rimeUserDir}/download"
    fs.mkdirSync download unless fs.existsSync download
    @downloadDirectory = "#{download}/#{@props.name}"
    fs.mkdirSync @downloadDirectory unless fs.existsSync @downloadDirectory
    total = @props.files.length
    success = failure = 0
    finish = ->
      return unless success + failure == total
      if failure
        callback(new Error "failed to download #{failure}/#{total} files.")
      else
        callback()
    for fileUrl in @props.files
      do (fileUrl) =>
        fileName = url.parse(fileUrl).pathname.split('/').pop()
        console.log "downloading #{fileName}"
        dest = "#{@downloadDirectory}/#{fileName}"
        request.get(fileUrl)
          .on('error', (e) ->
            console.log "got error: #{e.message}"
            ++failure
            finish()
          )
          .on('end', =>
            console.log "#{fileName} downloaded to #{@downloadDirectory}"
            ++success
            finish()
          )
          .pipe fs.createWriteStream(dest)

  # callback: (err) ->
  copyFile: (src, callback) ->
    fileName = path.basename src
    dest = "#{@rimeUserDir}/#{fileName}"
    fs.createReadStream(src)
      .on('error', (e) ->
        console.log "error copying file: #{e.message}"
        callback e
      )
      .on('end', =>
        console.log "#{fileName} copied to #{@rimeUserDir}"
        callback()
      )
      .pipe fs.createWriteStream(dest)

  # callback: (err) ->
  installSchema: (schemaId, callback) ->
    unless @downloadDirectory?
      callback(new Error "no files to install for schema '#{schemaId}'")
      return
    schemaFile = "#{@downloadDirectory}/#{schemaId}.schema.yaml"
    files = [schemaFile]
    c = new Config
    c.loadFile schemaFile, (err) =>
      if err
        callback err
        return
      dictId = c.get 'translator/dictionary'
      if dictId
        dictFile = "#{@downloadDirectory}/#{dictId}.dict.yaml"
        if fs.existsSync dictFile
          files.push dictFile
      # install files
      total = files.length
      success = failure = 0
      for file in files
        @copyFile file, (err) ->
          if err then ++failure else ++success
          return unless success + failure == total
          if failure
            callback(new Error "failed to copy #{failure}/#{total} files.")
          else
            callback()

  findConfigFile: (fileName) ->
    path = "#{@rimeUserDir}/#{fileName}"
    if fs.existsSync path
      c = new Config
      try
        c.loadFileSync path
        unless typeof c.get('customization') is 'number'
          return path
      catch e
    if @rimeSharedDir != @rimeUserDir
      path = "#{@rimeSharedDir}/#{fileName}"
      if fs.existsSync path
        return path
    null

  getDefaultSchemaList: ->
    c = new Config
    c.loadFile @findConfigFile('default.yaml'), (err) ->
      return [] if err
      c.get('schema_list') or []

  # callback: (err) ->
  # edit: (schemaList) ->
  editSchemaList: (callback, edit) ->
    @customize 'default', callback, (c) =>
      list = c.root.patch['schema_list'] or @getDefaultSchemaList()
      edit list
      c.patch 'schema_list', list

  # callback: (err) ->
  enableSchema: (schemaId, callback) ->
    @editSchemaList callback, (schemaList) ->
      unless schemaId in schemaList
        schemaList.push schemaId

  # callback: (err) ->
  disableSchema: (schemaId, callback) ->
    @editSchemaList callback, (schemaList) ->
      if ~(index = schemaList.indexOf schemaId)
        schemaList.splice index, 1

  # callback: (err) ->
  # edit: (customizer) ->
  customize: (configId, callback, edit) ->
    configPath = "#{@rimeUserDir}/#{configId}.custom.yaml"
    c = new Customizer
    finish = (c) ->
      edit c
      c.saveFile configPath, callback
    fs.exists configPath, (exists) ->
      if exists
        c.loadFile configPath, (err) ->
          if err
            callback err
          else
            finish c
      else
        finish c
