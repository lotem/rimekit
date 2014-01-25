rime = require '../app.nw/rime'
path = require 'path'

argv = process.argv

if argv.length < 3
  console.log "usage: #{argv[0]} #{path.basename argv[1]} recipe [key=value ...]"
  process.exit 1

recipeScript = argv[2]
console.log "recipe: #{recipeScript}"

ingredients = {}
for x in argv.slice(3)
  [k, v] = x.split '='
  unless k and v
    console.error "invalid ingredient: #{x}"
  ingredients[k] = v
console.log "ingredients: #{JSON.stringify ingredients}"

rime.runUserScript recipeScript, ingredients, (err) ->
  if err
    console.error err
  else
    console.log 'done.'
