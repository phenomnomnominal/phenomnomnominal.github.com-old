projects = ['tuner']

clear = 
  projects: (callback) ->
    $('.project').addClass('offLeft').promise().done ->
      callback()
      $('.project').removeClass('offLeft')
      $('.project').addClass('spinLeft')
    $('.back').removeClass('offLeft')
  displays: ->
    $('.display').addClass 'offRight'
    $('.back').addClass('offLeft').promise().done ->
      window.location.href = 'http://phenomnomnominal.github.com/'

show =
  projects: ->
    $('.project').removeClass 'spinLeft'

load = 
  tuner: ->
    $('.tuner').removeClass 'offRight'
    Tuner()
  transcribe: ->
  quantum: ->
    
$ ->
  show.projects()
  
  $('.project').click ->
    clear.projects load[$(this).attr 'title']
    
  $('.back').click ->
    clear.displays()
    show.projects()