clear = 
  projects: (callback) ->
    $('.project').animate(left: -2000).promise().done callback

show =
  projects: ->
    $('.project').removeClass 'offLeft'

load = 
  tuner: ->
    Tuner()
  transcribe: ->
  quantum: ->
    
$ ->
  show.projects()
  
  $('.project').click ->
    clear.projects load[$(this).attr 'title']
      
      