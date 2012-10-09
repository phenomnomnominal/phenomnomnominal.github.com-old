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
  tuner: ->
    $('.tuner').show ->
      $('.tuner').removeClass 'offRight'
      $('.tuner header').addClass 'active'
      Tuner()
  tetris: ->
    $('.tetris').show ->
      $('.tetris').removeClass 'offRight'
      $('.tetris header').addClass 'active'
      Tetris()
    
$ ->
  show.projects()
  
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