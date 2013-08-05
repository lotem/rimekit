YAML = require('yamljs')

angular.module('RimeToolsModule', []).
  filter 'toyaml', ->
    (input) ->
      YAML.stringify(input ? '')

window.AlgebraCtrl = ($scope) ->
  $scope.rules = [
    {formula: 'xlit/abc/ABC/', applied: true}
    {formula: 'xform/abc/def/', applied: false}
  ]
  $scope.applyRules = ->
    angular.forEach $scope.rules, (rule) ->
      0

# vim: set et sw=2 sts=2:
