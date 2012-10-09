clear = 
  projects: (callback) ->
    $('header').removeClass 'active'
    $('.project').addClass('offLeft').promise().done ->
      callback()
      $('.project').removeClass('offLeft').addClass 'spinLeft'
      $('.back').show ->
        $('.back').removeClass 'offLeft'
  displays: ->
    $('.display').addClass 'offRight'
    $('.back').addClass('offLeft').promise().done ->
      $('.back').hide()
      window.location.href = 'http://phenomnomnominal.github.com/'

show =
  projects: ->
    $('.project').show ->
      $('.project').removeClass 'spinLeft'

load = 
  clouds: ->
    $('.clouds').show ->
      $('.clouds').removeClass 'offRight'
      $('.clouds header').addClass 'active'
      Clouds()
  tetris: ->
    $('.tetris').show ->
      $('.tetris').removeClass 'offRight'
      $('.tetris header').addClass 'active'
      Tetris()
  tuner: ->
    $('.tuner').show ->
      $('.tuner').removeClass 'offRight'
      $('.tuner header').addClass 'active'
      Tuner()
    
$ ->
  show.projects()
  
  window.requestAnimFrame = (->
    window.requestAnimationFrame or
    window.webkitRequestAnimationFrame or
    window.mozRequestAnimationFrame or
    window.oRequestAnimationFrame or
    window.msRequestAnimationFrame or
    (callback) -> window.setTimeout(callback, 1000 / 60))()
  
  $(window).scroll ->
    scrollAnchor = $('.scrollAnchor').offset().top
    if $(this).scrollTop() >= scrollAnchor and $('.active').css('position') isnt 'fixed'
      $('.scrollAnchor').css 'height', $('.active h2').outerHeight()
      $('.back').removeClass('animate').addClass 'topHeader'
      $('.active').addClass 'topHeader'
    else if $(this).scrollTop() < scrollAnchor and $('.active').css('position') isnt 'relative'
      $('.scrollAnchor').css 'height', '0px'
      $('.back').removeClass 'topHeader'
      $('.active').removeClass 'topHeader'

  $('.project').click ->
    clear.projects load[$(this).attr 'id']

  $('.back').click ->
    clear.displays()
    show.projects()