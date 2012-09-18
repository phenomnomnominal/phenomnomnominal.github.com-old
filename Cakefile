{spawn, exec} = require 'child_process'

task 'compile', 'compile everything', ->
  files = ['transcribe.coffee']
  joinOrder = ''
  joinOrder += "'coffeescript/#{file}' " for file in files
  exec "coffee -j javascript/transcribe.js -cw #{joinOrder}"
  console.log 'Done compile, now watching for changes...'
  
task 'lint', 'run Coffeelint on all CoffeeScripts', ->
  lint = exec "coffeelint -r coffeescript"
  lint.stdout.on 'data', (data) -> console.log data.toString().trim()
  lint.stderr.on 'data', (data) -> console.log data.toString().trim()
  console.log 'Done lint'
  
task 'all', 'compile everything and create the docs', ->
  console.log 'Running compile...'
  invoke 'compile'
  console.log 'Running Coffeelint'
  invoke 'lint'