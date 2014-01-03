app = angular.module 'rimekit', ['ui.bootstrap']

customRimeUserDir = ->
  try
    key = require('windows')?.registry('HKCU/Software/Rime/Weasel')
  catch
    console.warn 'could not access Windows registry.'
  key?.RimeUserDir?.value

app.factory 'rimekitService', ->
  console.log "version: #{process.version}"
  console.log "platform: #{process.platform}"
  if process.platform == 'darwin'
    home = process.env['HOME'] ? '.'
    rimeDirectory = "#{home}/Library/Rime"
  else if process.platform == 'linux'
    home = process.env['HOME'] ? '.'
    rimeDirectory = "#{home}/.config/ibus/rime"
  else if process.platform == 'win32'
    appdata = process.env['APPDATA']
    rimeDirectory = customRimeUserDir() or "#{appdata}\\Rime"
  console.log "Rime directory: #{rimeDirectory}"
  nodeVersion: process.version
  platform: process.platform
  rimeDirectory: rimeDirectory

app.controller 'MainCtrl', ($scope) ->
  $scope.tabs =
    brise:
      title: '東風破.net'
      source: 'brise.html'
      disabled: true
    sadebugger:
      title: '拼寫運算調試器'
      source: 'sadebugger.html'
