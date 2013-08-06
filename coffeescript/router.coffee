(exports ? @).Routing = do ->
  _router = new Router()

  _currentSection = 'home'
  
  _setCurrentSection = (newSection) ->
    _currentSection = newSection
    document.title = "Craig Spence | #{_currentSection.toUpperCase()}"
    $('section').removeClass('current').filter("##{_currentSection}").addClass('current')

  init = ->
    _router.route '/*path', -> Projects.kill()
    _router.route '/home', -> Scenes.change 'home', -> _setCurrentSection 'home'
    _router.route '/projects', ->
      Scenes.change 'projects', ->
        _setCurrentSection 'projects'
    _router.route '/projects/:project', (project) ->
      Scenes['projects/project'].blockGroups[4] = Blocks.makeProjectTitle project
      Scenes.change 'projects/project', -> 
        _setCurrentSection 'project'
        Projects.init project
    _router.route '/social', -> Scenes.change 'social', -> _setCurrentSection 'social'
    _router.route '/blog', -> Scenes.change 'blog', -> _setCurrentSection 'blog'
    _router.route '/cv', -> Scenes.change 'cv', -> _setCurrentSection 'cv'

    params = window.location.search.substring(1).split '&'
    for param in params
       [key, value] = param.split '='
       redirect = decodeURIComponent(value) if key is 'redirect'
    redirect ?= 'home'
    redirect = redirect.substr(0, redirect.length - 1) if redirect.substr(-1) is '/'
    redirect = redirect.substr(1) if redirect.substr(0, 1) is '/'
    Routing.go redirect, true

  go = (name, replace = false) ->
    _router.navigate "/#{name.toLowerCase()}", true, replace

  back = ->
    if _currentSection in ['projects', 'social', 'blog', 'cv']
      _router.navigate '/home'
    if _currentSection is 'project'
      _router.navigate '/projects'

  init: init
  go: go
  back: back