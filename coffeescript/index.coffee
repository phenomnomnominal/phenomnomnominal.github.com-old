load =
  project: (title) ->
    project = projects[title]
    $('header div').fadeOut()
    $('nav').fadeIn()
    $('nav h2').text project.title
    for doc in project.docs
      listItem = $ '<li>'
        class: 'animate'
      listItem.append $ '<a>'
        href: doc.link
        target: '_blank'
        text: doc.title
      $('nav ul').append listItem
    $('nav *').removeClass('offRight offLeft')
    $('nav div').hover (-> $('nav ul').show()), (-> $('nav ul').hide())
    project.init()

clear = 
  projects: ->
    $('.project-list').addClass 'offLeft'
      
  displays: ->
    $('header div').fadeIn()
    $('nav').fadeOut()
    $('.display').addClass 'offRight'
    $('.back').addClass('offLeft').promise().done ->
      $('nav *').addClass 'offRight'
      window.location.href = 'http://phenomnomnominal.github.com/'

show =
  projects: ->
    $('.project').show().delay(1000).promise().done ->
      $('.project').removeClass 'offLeft'

projects = 
  clouds: 
    init: ->
      $('.clouds').show().delay(1000).promise().done ->
        $('.clouds').removeClass 'offRight'
        Clouds()
    docs: [
        link: 'docs/clouds.html', title: 'clouds.coffee'
      ]
    title: 'DYNAMIC CLOUDS'
  tetris: 
    init: ->
      $('.tetris').show().delay(1000).promise().done ->
        $('.tetris').removeClass 'offRight'
        Tetris()
    docs: [
        {link: 'docs/tetris.html', title: 'tetris.coffee'}
        {link: 'docs/tetrominoes.html', title: 'tetrominoes.coffee'}
      ]
    title: 'TETRIS AI'
  tuner:
    init: ->
      $('.tuner').show().delay(1000).promise().done ->
        $('.tuner').removeClass 'offRight'
        Tuner()
    docs: [
        link: 'docs/tuner.html', title: 'tuner.coffee'
      ]
    title: 'PURE JAVASCRIPT GUITAR TUNER'  
    
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
    navAnchorTop = $('.nav-anchor').offset().top
    if $(this).scrollTop() >= navAnchorTop and $('nav').css('position') isnt 'fixed'
      $('nav').addClass 'stick'
    else if $(this).scrollTop() < navAnchorTop and $('nav').css('position') is 'fixed'
      $('nav').removeClass 'stick'

  $('.project').click ->
    clear.projects()
    load.project $(this).attr 'id'

  $('.back').click ->
    clear.displays()
    show.projects()