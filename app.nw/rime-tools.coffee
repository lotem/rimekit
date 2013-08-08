fs = require('fs')

angular.module('RimeToolsModule', [])

window.AlgebraCtrl = ($scope) ->
  $scope.schemaId = 'luna_pinyin'
  $scope.configKey = 'speller/algebra'
  $scope.rules = []

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
    config.loadFile filePath
    @dictName = config.get 'translator/dictionary' ? ''
    ruleList = config.get @configKey
    @rules.length = 0
    @rules.push new Rule(x) for x in ruleList if ruleList
    console.log "#{@rules.length} rules loaded."

  $scope.loadDict = ->
    return unless @dictName
    filePath = "#{@rimeDirectory ? '.'}/#{@dictName}.table.bin"
    table = new Table
    table.loadFile filePath, (syllabary) ->
      console.debug syllabary

  $scope.select = (index) ->
    console.log "select: #{index}"
