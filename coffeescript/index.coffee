clear = 
  projects: (callback) ->
    $('.project').animate(left: -2000).promise().done callback

load = 
  tuner: ->
  transcribe: ->
  quantum: ->
    
$ ->
  $('.project').removeClass 'offscreen'
  
  $('.project').click ->
    clear.projects load[$(this).attr 'title']
      
      