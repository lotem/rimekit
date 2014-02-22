# done in index.html instead
#app = angular.module 'rimekit', ['ui.bootstrap']

customRimeUserDir = ->
  try
    key = require('windows')?.registry('HKCU/Software/Rime/Weasel')
  catch
    console.warn 'could not access Windows registry.'
  key?.RimeUserDir?.value

weaselInstallDir = ->
  try
    key = require('windows')?.registry('HKLM/Software/Rime/Weasel')
  catch
    console.warn 'could not access Windows registry.'
  key?.WeaselRoot?.value

app.factory 'rimekitService', ->
  console.log "version: #{process.version}"
  console.log "platform: #{process.platform}"
  if process.platform == 'darwin'
    home = process.env['HOME'] ? '.'
    rimeUserDir = "#{home}/Library/Rime"
    rimeSharedDir = "/Library/Input Methods/Squirrel.app/Contents/SharedSupport"
  else if process.platform == 'linux'
    home = process.env['HOME'] ? '.'
    rimeUserDir = "#{home}/.config/ibus/rime"
    rimeSharedDir = "/usr/share/rime-data"
  else if process.platform == 'win32'
    appdata = process.env['APPDATA']
    rimeUserDir = customRimeUserDir() or "#{appdata}\\Rime"
    rimeSharedDir = "#{weaselInstallDir()}\\data"
  console.log "Rime user directory: #{rimeUserDir}"
  console.log "Rime shared directory: #{rimeSharedDir}"
  nodeVersion: process.version
  platform: process.platform
  rimeUserDir: rimeUserDir
  rimeSharedDir: rimeSharedDir

app.controller 'MainCtrl', ($scope) ->
  $scope.tabs =
    b_brise:
      title: '東風破.net'
      source: 'brise.html'
    c_sadebugger:
      title: '拼寫運算調試器'
      source: 'sadebugger.html'
    d_cseditor:
      title: '配色編輯器'
    e_credits:
      title: '創作者'
      source: 'credits.html'
  $scope.links =
    blog: 'http://rimeime.github.io'
    project: 'http://code.google.com/p/rimeime/'
  $scope.openLink = (url) ->
    require('nw.gui').Shell.openExternal url
