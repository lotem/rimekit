fs = require('fs')

app = angular.module 'rimekit', []

app.controller 'AlgebraCtrl', ($scope) ->
  $scope.schemaId = 'luna_pinyin'
  $scope.configKey = 'speller/algebra'
  $scope.rules = []
  $scope.syllabary = []

  $scope.init = ->
    console.log "platform: #{process.platform}"
    if process.platform == 'darwin'
      home = process.env['HOME'] ? '.'
      @rimeDirectory = "#{home}/Library/Rime"
    else if process.platform == 'linux'
      home = process.env['HOME'] ? '.'
      @rimeDirectory = "#{home}/.config/ibus/rime"
    else if process.platform == 'win32'
      appdata = process.env['APPDATA']
      @rimeDirectory = "#{appdata}/Rime"
    console.log "Rime directory: #{@rimeDirectory}"

  $scope.loadSchema = ->
    return unless @schemaId && @configKey
    filePath = "#{@rimeDirectory ? '.'}/#{@schemaId}.schema.yaml"
    unless fs.existsSync filePath
      console.warn "file does not exist: #{filePath}"
      return
    config = new Config
    config.loadFile filePath, =>
      @$apply =>
        @dictName = config.get 'translator/dictionary' ? ''
        rules = config.get @configKey
        @rules = (new Rule(x) for x in rules) if rules
        console.log "#{@rules.length} rules loaded."

  $scope.loadDict = ->
    return unless @dictName
    filePath = "#{@rimeDirectory ? '.'}/#{@dictName}.table.bin"
    table = new Table
    table.loadFile filePath, (syllabary) =>
      @$apply =>
        @syllabary = syllabary
        console.log "#{@syllabary.length} syllables loaded."

  $scope.select = (index) ->
    console.log "select: #{index}"
