rime = require '../app.nw/rime'

if process.argv.length < 3
  console.log 'missing script file.'
  process.exit 1

rime.runUserScript process.argv[2], (err) ->
  console.log err if err
