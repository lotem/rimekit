vm = require 'vm'
path = require 'path'

exports.UserScript = class UserScript
  constructor (@code) ->

  loadFile: (filePath, callback) ->
    fs.readFile filePath, {encoding: 'utf8'}, (err, data) =>
      if err
        callback err
        return
      @code = data
      callback()

  compile: ->
    @script = vm.createScript @code

  run: (sandbox = {}) ->
    @script.runInNewContext sandbox

exports.UserCoffeeScript = class UserCoffeeScript extends UserScript
  compile: ->
    coffee = require 'coffee-script'
    @script = vm.createScript(coffee.compile @code)

exports.runUserScript = (filePath, ingredients, callback) ->
  script = new (
    if path.extname(filePath) is '.coffee' then UserCoffeeScript else UserScript
  )
  script.loadFile filePath, (err) ->
    if err
      callback err
      return
    try
      script.compile()
      sandbox = {}
      for key, value of exports
        sandbox[key] = value
      sandbox.ingredients = ingredients
      script.run sandbox
    catch e
      callback e
      return
    callback()
