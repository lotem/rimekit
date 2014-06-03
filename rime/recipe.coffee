fs = require 'fs'
path = require 'path'
request = require 'request'
url = require 'url'

exports.RecipeList = class RecipeList

  constructor: (@fileName = 'recipes.yaml')->
    @loaded = false
    @loading = false
    @list = []
    @pending = []
    @autoSave = true

  schedule: (work) ->
    @pending.push work
    if @loading
      return
    doPendingWork = =>
      while @pending.length != 0
        @pending.shift()()
      @save() if @autoSave
    if @loaded
      doPendingWork()
    else
      @load (err) =>
        throw err if err
        doPendingWork()

  load: ->
    new Promise (resolve, reject) =>
      filePath = "#{Recipe.rimeUserDir}/#{@fileName}"
      c = new Config
      (
        if fs.existsSync filePath
          @loading = true
          c.loadFile(filePath)
        else
          Promise.resolve()
      )
      .then =>
        @loading = false
        @loaded = true
        @list = c.get('recipes') or []
        resolve()
      .catch (err) =>
        @loading = false
        reject err

  save: ->
    filePath = "#{Recipe.rimeUserDir}/#{@fileName}"
    c = new Config
    c.set 'recipes', @list
    c.saveFile filePath

  clear: ->
    @schedule =>
      @list = []

  add: (recipe) ->
    @schedule =>
      @list.push
        name: recipe.props.name
        version: recipe.props.version
        params: recipe.params

exports.recipes = recipes = new RecipeList

# recipe: Recipe or {...}
# ingredients: {...}
exports.cook = cook = (recipe, ingredients) ->
  try
    unless recipe instanceof Recipe  # cook {...}, ...
      recipe = new Recipe recipe
    if recipe.props.params
      recipe.collectParams(ingredients ? {})
  catch e
    console.error "error parsing recipe: #{e}"
    return Promise.reject e
  recipe.downloadFiles()
  .then ->
    if recipe.props.setup
      recipe.props.setup.call recipe
  .then ->
    # save recipe list
    recipes.add recipe
  .catch (e) ->
    console.error "error cooking recipe: #{e}"
    return Promise.reject e

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

  downloadFiles: ->
    unless @props.files  # no files needed to download
      return Promise.resolve()
    download = "#{@rimeUserDir}/download"
    fs.mkdirSync download unless fs.existsSync download
    @downloadDirectory = "#{download}/#{@props.name}"
    fs.mkdirSync @downloadDirectory unless fs.existsSync @downloadDirectory
    total = @props.files.length
    downloadFile = (fileUrl) =>
      new Promise (resolve, reject) =>
        fileName = url.parse(fileUrl).pathname.split('/').pop()
        console.log "downloading #{fileName}"
        dest = "#{@downloadDirectory}/#{fileName}"
        request.get(fileUrl)
        .on('error', (e) ->
          console.log "failed to download #{fileName}: #{e.message}"
          reject e
        )
        .on('end', =>
          console.log "#{fileName} downloaded to #{@downloadDirectory}"
          resolve()
        )
        .pipe fs.createWriteStream(dest)
    Promise.all(@props.files.map downloadFile)

  copyFile: (src) ->
    new Promise (resolve, reject) =>
      fileName = path.basename src
      dest = "#{@rimeUserDir}/#{fileName}"
      fs.createReadStream(src)
      .on('error', (e) ->
        console.log "error copying file: #{e.message}"
        reject e
      )
      .on('end', =>
        console.log "#{fileName} copied to #{@rimeUserDir}"
        resolve()
      )
      .pipe fs.createWriteStream(dest)

  installSchema: (schemaId) ->
    unless @downloadDirectory?
      return Promise.reject(
        new Error "no files to install for schema '#{schemaId}'"
      )
    schemaFile = "#{@downloadDirectory}/#{schemaId}.schema.yaml"
    files = [schemaFile]
    c = new Config
    c.loadFile(schemaFile)
    .then =>
      dictId = c.get 'translator/dictionary'
      if dictId
        dictFile = "#{@downloadDirectory}/#{dictId}.dict.yaml"
        if fs.existsSync dictFile
          files.push dictFile
      Promise.all(files.map (x) => @copyFile x)

  findConfigFile: (fileName) ->
    filePath = "#{@rimeUserDir}/#{fileName}"
    if fs.existsSync filePath
      c = new Config
      try
        c.loadFileSync filePath
        unless typeof c.get('customization') is 'number'
          return filePath
      catch e
    if @rimeSharedDir != @rimeUserDir
      filePath = "#{@rimeSharedDir}/#{fileName}"
      if fs.existsSync filePath
        return filePath
    null

  getDefaultSchemaList: ->
    c = new Config
    c.loadFile(@findConfigFile 'default.yaml')
    .then ->
      c.get('schema_list') or []
    .catch ->
      []

  # edit: (schemaList) ->
  editSchemaList: (edit) ->
    @customize 'default', (c) =>
      (
        list = c.root.patch['schema_list']
        if list?
          Promise.resolve(list)
        else
          @getDefaultSchemaList()
      )
      .then (list) ->
        edit list
        c.patch 'schema_list', list

  enableSchema: (schemaId) ->
    @editSchemaList (schemaList) ->
      unless schemaId in schemaList
        schemaList.push schemaId

  disableSchema: (schemaId) ->
    @editSchemaList (schemaList) ->
      if ~(index = schemaList.indexOf schemaId)
        schemaList.splice index, 1

  # edit: (customizer) ->
  customize: (configId, edit) ->
    configPath = "#{@rimeUserDir}/#{configId}.custom.yaml"
    c = new Customizer
    (
      if fs.existsSync configPath
        c.loadFile configPath
      else
        Promise.resolve()
    )
    .then ->
      edit c
      c.saveFile configPath
