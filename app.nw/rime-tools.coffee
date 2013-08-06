fs = require('fs')
YAML = require('yamljs')

angular.module('RimeToolsModule', [])
  .filter 'toyaml', ->
    (input) ->
      YAML.stringify(input ? '')

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
    @rimeDirectory = "/home/Rime"  # DEBUG

  $scope.reload = ->
    return unless @schemaId && @configKey
    filePath = "#{@rimeDirectory ? '.'}/#{@schemaId}.schema.yaml"
    unless fs.existsSync filePath
      console.warn "file does not exist: #{filePath}"
      return
    node = YAML.load filePath
    for key in @configKey.split '/'
      break unless node?
      node = node[key]
    @rules.length = 0
    @rules.push {formula: x, applied: false} for x in node
    console.debug "#{@rules.length} rules loaded."

  $scope.select = (index) ->
    console.log "select: #{index}"
