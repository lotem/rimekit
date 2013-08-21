fs = require('fs')

app.controller 'AlgebraCtrl', ($scope, rimekitService) ->
  $scope.configKeys = [
    'speller/algebra'
    'translator/preedit_format'
    'translator/comment_format'
    'reverse_lookup/preedit_format'
    'reverse_lookup/comment_format'
  ]

  $scope.rimeDirectory = rimekitService.rimeDirectory
  $scope.schemaId = 'luna_pinyin'
  $scope.configKey = 'speller/algebra'
  $scope.rules = []
  $scope.syllabary = []

  $scope.init = ->

  $scope.loadSchema = ->
    @rules = []
    @syllabary = []
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
        @calculate()

  $scope.loadDict = ->
    @syllabary = []
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
