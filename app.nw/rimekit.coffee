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
    @rules = []
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
        @isProjector = @configKey.match(/\/algebra$/) != null
        @isFormatter = @configKey.match(/format$/) != null

  $scope.loadDict = ->
    $scope.syllabary = []
    return unless @dictName
    filePath = "#{@rimeDirectory ? '.'}/#{@dictName}.table.bin"
    table = new Table
    table.loadFile filePath, (syllabary) =>
      @$apply =>
        @syllabary = syllabary
        console.log "#{@syllabary.length} syllables loaded."
        @calculate()

  $scope.select = (index) ->
    console.log "select: #{index}"

  $scope.calculate = ->
    algebra = new Algebra @rules
    if @isProjector
      @testScript = Script.fromSyllabary @syllabary
      console.log "calulate: #{@testScript}"
      algebra.makeProjection @testScript
    if @isFormatter
      console.log "calulate: #{@testString}"
      algebra.formatString @testString
