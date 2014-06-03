vm = require 'vm'
path = require 'path'

exports.UserScript = class UserScript
  constructor (@code) ->

  loadFile: (filePath) ->
    new Promise (resolve, reject) =>
      fs.readFile filePath, {encoding: 'utf8'}, (err, data) =>
        if err
          reject err
        else
          @code = data
          resolve()

  compile: ->
    @script = vm.createScript @code

  run: (sandbox = {}) ->
    @script.runInNewContext sandbox

exports.UserCoffeeScript = class UserCoffeeScript extends UserScript
  compile: ->
    coffee = require 'coffee-script'
    @script = vm.createScript(coffee.compile @code)

exports.runUserScript = (filePath, ingredients) ->
  script = new (
    if path.extname(filePath) is '.coffee' then UserCoffeeScript else UserScript
  )
  script.loadFile(filePath)
  .then ->
    try
      script.compile()
      sandbox = {}
      for key, value of exports
        sandbox[key] = value
      sandbox.ingredients = ingredients
      sandbox.cook = (recipe, ingredients) ->
        sandbox.result = Promise.resolve().then ->
          cook recipe, ingredients
      script.run sandbox
      sandbox.result
    catch e
      return Promise.reject e
