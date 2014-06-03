fs = require('fs')
diff = require('diff')
escape = require('escape-html')
rime = require('./rime')

stringDiff = (x, element, attrs) ->
  oldValue = x?.previous?.toString() ? ''
  newValue = x?.toString() ? ''
  if oldValue == newValue
    element.text newValue
    return
  diffMethod =
    if attrs.unit is 'char' then diff.diffChars else diff.diffWords
  changes = diffMethod(oldValue, newValue)
  element.html diff.convertChangesToXML(changes)

scriptDiff = (x, element, attrs) ->
  unless x?.previous?
    element.text x?.toString() ? ''
    return
  compareSpellingByText = (a, b) ->
    if a.text < b.text then -1 else if a.text > b.text then 1 else 0
  os = x.previous.getSpellings().sort compareSpellingByText
  ns = x.getSpellings().sort compareSpellingByText
  changes = []
  while os.length > 0 and ns.length > 0
    ot = os[0].text
    nt = ns[0].text
    if ot < nt
      os.shift()
      changes.push '<del>' + escape(ot) + '</del>'
    else if ot > nt
      ns.shift()
      changes.push '<ins>' + escape(nt) + '</ins>'
    else
      if os.shift() isnt ns.shift()
        changes.push '<em>' + escape(nt) + '</em>'
      else  # no change
        changes.push escape(nt)
  while os.length > 0
    changes.push '<del>' + escape(os.shift().text) + '</del>'
  while ns.length > 0
    changes.push '<ins>' + escape(ns.shift().text) + '</ins>'
  element.html changes.join ' '

app.directive 'diff', ->
  restrict: 'E'
  link: (scope, element, attrs) ->
    scope.$watch attrs.value, (x) ->
      if attrs.type is 'script'
        scriptDiff(x, element, attrs)
      else
        stringDiff(x, element, attrs)

app.directive 'query', ->
  restrict: 'E'
  scope:
    update: '&'
    visible: '@'
  controller: ($scope) ->
    $scope.change = ->
      console.debug 'change:', @value
      @pattern = @error = null
      if @value
        try
          @pattern = new RegExp @value
        catch error
          console.error "bad query: #{error}"
          @error = error
  template: '''<div ng-show="visible">
    <form class="form-search" style="margin: 20px;">
      <div class="input-append control-group" ng-class="{error: error}">
        <input type="text" class="span2 search-query" ng-trim="false" ng-model="value" ng-change="change()">
        <button type="submit" class="btn" ng-disabled="error" ng-click="update({query:pattern})">查詢</button>
      </div>
    </form>
  </div>'''

app.controller 'AlgebraCtrl', ($scope, rimekitService) ->
  $scope.configKeys = [
    'speller/algebra'
    'translator/preedit_format'
    'translator/comment_format'
    'reverse_lookup/preedit_format'
    'reverse_lookup/comment_format'
  ]

  $scope.rimeUserDir = rimekitService.rimeUserDir
  $scope.schemaId = 'luna_pinyin'
  $scope.configKey = 'speller/algebra'
  $scope.rules = []
  $scope.syllabary = []
  $scope.alerts = []

  $scope.init = ->

  $scope.loadSchema = ->
    @rules = []
    @syllabary = []
    @alerts.length = 0
    return unless @schemaId && @configKey
    filePath = "#{@rimeUserDir ? '.'}/#{@schemaId}.schema.yaml"
    unless fs.existsSync filePath
      console.warn "file does not exist: #{filePath}"
      @alerts.push type: 'error', msg: '找不到輸入方案'
      return
    config = new rime.Config
    config.loadFile(filePath)
    .then =>
      @$apply =>
        @dictName = config.get 'translator/dictionary' ? ''
        rules = config.get @configKey
        @rules = (new rime.Rule(x) for x in rules) if rules
        console.log "#{@rules.length} rules loaded."
        if @rules.length != 0
          @rules.unshift new rime.Rule  # initial state
        @isProjector = @configKey.match(/\/algebra$/) != null
        @isFormatter = @configKey.match(/format$/) != null
        @calculate()
    .catch (err) =>
      @$apply =>
        @alerts.push type: 'error', msg: '載入輸入方案錯誤'

  $scope.loadDict = ->
    @syllabary = []
    @alerts.length = 0
    return unless @dictName
    filePath = "#{@rimeUserDir ? '.'}/#{@dictName}.table.bin"
    table = new rime.Table
    table.loadFile(filePath)
    .then =>
      @$apply =>
        @syllabary = table.syllabary
        console.log "#{@syllabary.length} syllables loaded."
        @calculate()
    .catch (err) =>
      @$apply =>
        @alerts.push type: 'error', msg: '載入詞典錯誤'

  $scope.calculate = ->
    if @rules.length == 0
      @alerts.push type: 'error', msg: '無有定義拼寫運算規則'
      return
    algebra = new rime.Algebra @rules
    if @isProjector and @syllabary.length
      console.log "calulate: [#{@syllabary.length} syllables]"
      algebra.makeProjection rime.Script.fromSyllabary @syllabary
      for r in @rules
        r.queryResult = r.script
    if @isFormatter and @testString
      console.log "calulate: \"#{@testString}\""
      algebra.formatString @testString ? ''

  $scope.closeAlert = (index) ->
    @alerts.splice index, 1

  $scope.querySpellings = (index, pattern) ->
    console.log 'querySpellings:', index, pattern
    return unless @rules[index]?.script

    unless pattern
      for r in @rules
        r.queryResult = r.script
      console.log 'cleared query result.'
      return

    q = @rules[index].queryResult = @rules[index].script.query pattern

    r = q
    for j in [index - 1..0] by -1
      r = @rules[j].queryResult = r.queryPrevious @rules[j].script

    r = q
    for j in [index + 1...@rules.length]
      r = @rules[j].queryResult = r.queryNext @rules[j].script
