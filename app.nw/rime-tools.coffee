YAML = require('yamljs')

angular.module('RimeToolsModule', []).
  filter 'yamldoc', ->
    (input) ->
      YAML.stringify(input ? '')

window.TodoCtrl = ($scope) ->
  $scope.todos = [
    {text:'learn angular', done:true}
    {text:'build an angular app', done:false}
  ]
  $scope.addTodo = ->
    $scope.todos.push {text:$scope.todoText, done:false}
    $scope.todoText = ''
  $scope.remaining = ->
    count = 0
    angular.forEach $scope.todos, (todo) ->
      count += todo.done ? 0 : 1
    return count
  $scope.archive = ->
    oldTodos = $scope.todos
    $scope.todos = []
    angular.forEach oldTodos, (todo) ->
      $scope.todos.push(todo) unless todo.done

# vim: set et sw=2 sts=2:
