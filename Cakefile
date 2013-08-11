{spawn, exec} = require 'child_process'
fs = require 'fs'
path = require 'path'

PROJECT_ROOT = path.dirname fs.realpathSync __filename
BLOG_ROOT = path.join PROJECT_ROOT, 'blog'
CV_ROOT = path.join PROJECT_ROOT, 'cv'

task 'coffee', 'compile the CoffeeScript', ->
  console.log 'Running CoffeeScript compile...'
  exec 'coffee -j javascript/scripts.js -cw coffeescript/*.coffee'
  console.log 'Done CoffeeScript compile, watching for changes...'

task 'scss', 'compile the SCSS', ->
  console.log 'Running SCSS compile...'
  exec 'sass --watch styles/style.scss:style.css'
  exec 'sass --watch styles/mobile-style.scss:mobile-style.css'
  console.log 'Done SCSS compile, watching for changes...'

task 'projects', 'compile the projects', ->
  console.log 'Running CoffeeScript compile for projects...'
  console.log 'Compiling Tetris:'
  exec 'coffee -o javascript -cw coffeescript/projects/tetris/tetrisWorker.coffee'
  tetrisFiles = ['tetris', 'tetrisAI', 'tetrisGrid', 'tetrominoes']
  tetrisFiles = ("coffeescript/projects/tetris/#{tetrisFile}.coffee" for tetrisFile in tetrisFiles)
  console.log "coffee -j javascript/tetris.js -cw #{tetrisFiles.join ' '}"
  exec "coffee -j javascript/tetris.js -cw #{tetrisFiles.join ' '}"
  console.log 'Done Tetris compile.'
  console.log 'Done CoffeeScript compile for projects, watching for changes...'

task 'markdown', 'compile the Markdown', ->
  console.log 'Running Markdown compile...'
  fs.readdir BLOG_ROOT, (err, files) ->
    mdFiles = files.filter (file) -> 
      file.substr(-3) == '.md'
    mdFiles.forEach (file) ->
      exec "md2html #{path.join(BLOG_ROOT, file)} > #{path.join(BLOG_ROOT, file.substring(0, file.length - 3))}.html"
  exec 'md2html cv/cv.md > cv/cv.html'
  console.log 'Done Markdown compile.'

task 'all', 'compile everything', ->
  invoke 'scss'
  invoke 'coffee'
  invoke 'projects'
  invoke 'markdown'