{spawn, exec} = require 'child_process'

task 'compile', 'compile everything', ->
  files = ['index.coffee']
  joinOrder = ''
  joinOrder += "'coffeescript/#{file}' " for file in files
  exec "coffee -j javascript/index.js -cw #{joinOrder}"
  console.log 'Done compile, now watching for changes...'
  
task 'all', 'compile everything', ->
  console.log 'Running compile...'
  invoke 'compile'