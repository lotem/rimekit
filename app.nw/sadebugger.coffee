fs = require('fs')

app.directive 'diff', ->
  restrict: 'E'
  link: (scope, element, attrs) ->
    stringDiff = (x) ->
      oldValue = x?.previous?.toString() ? ''
      newValue = x?.toString() ? ''
      if oldValue == newValue
        element.text newValue
        return
      diffMethod =
        if attrs.unit is 'char' then JsDiff.diffChars else JsDiff.diffWords
      changes = diffMethod(oldValue, newValue)
      element.html JsDiff.convertChangesToXML(changes)

    scriptDiff = (x) ->
      unless x?.previous?
        element.text x?.toString() ? ''
        return
      escapeHTML = JsDiff.escapeHTML
      compareSpellingByText = (a, b) ->
        if a.text < b.text then -1 else if a.text > b.text then 1 else 0
      os = (v for k, v of x.previous.mapping).sort compareSpellingByText
      ns = (v for k, v of x.mapping).sort compareSpellingByText
      changes = []
      while os.length > 0 and ns.length > 0
        ot = os[0].text
        nt = ns[0].text
        if ot < nt
          os.shift()
          changes.push '<del>' + escapeHTML(ot) + '</del>'
        else if ot > nt
          ns.shift()
          changes.push '<ins>' + escapeHTML(nt) + '</ins>'
        else
          if os.shift() isnt ns.shift()
            changes.push '<em>' + escapeHTML(nt) + '</em>'
          else  # no change
            changes.push escapeHTML(nt)
      while os.length > 0
        changes.push '<del>' + escapeHTML(os.shift().text) + '</del>'
      while ns.length > 0
        changes.push '<ins>' + escapeHTML(ns.shift().text) + '</ins>'
      element.html changes.join ' '

    scope.$watch attrs.value, (x) ->
      if attrs.type is 'script'
        scriptDiff(x)
      else
        stringDiff(x)

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
      algebra.formatString @testString ? ''
