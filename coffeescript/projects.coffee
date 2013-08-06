(exports ? @).Projects = do ->
  _currentProject = null
  
  init = (project) ->
    $.getScript("/javascript/#{project}.js").done ->
      Rendering.initProject()
      _currentProject = project
      window[_currentProject].init $('#project-content')

  update = ->
    if _currentProject
      window[_currentProject].update()

  kill = ->
    if _currentProject
      window[_currentProject].kill()
      _currentProject = null
      Rendering.killProject()

  init: init
  update: update
  kill: kill