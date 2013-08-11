(exports ? @).Responsive = do ->
  _deviceType = null
  _animationFrameRequest = null
  
  _getDeviceType = ->
    if Modernizr.mediaqueries then do ->
      large = matchMedia("(min-width: 1025px)").matches
      medium = matchMedia("(min-width: 600px) and (max-width: 1024px)").matches
      small = matchMedia("(max-width: 600px)").matches 
      if large and Modernizr.webgl then 'largeWithGL'
      else if large then 'large'
      else if medium and Modernizr.webgl then 'mediumWithGL'
      else if medium then 'medium'
      else if small and Modernizr.webgl then 'smallWithGL'
      else if small then 'small'
    else
      'fail'

  $(window).resize (e) ->
    _newType = _getDeviceType()
    if _newType isnt _deviceType
      _kill[_deviceType]() if _deviceType
      cancelAnimationFrame _animationFrameRequest
      _init[_newType]()
      _deviceType = _newType
      Routing.go 'reload'
    _resize[_deviceType] e

  _init =
    largeWithGL: ->
      addDomEvents = ->
        document.body.addEventListener 'mousemove', UI.events.mousemove
        document.body.addEventListener 'fullscreenchange', UI.events.windowResize
        $(window).on 'resize', UI.events.windowResize
        $(window).trigger 'resize'

      [Main.scene, Main.camera] = Rendering.init()
      Events.init(Main.scene, Main.camera)
      Blocks.init ->
        Blog.init()
        CV.init()
        DeviceOrientation.init()
        Scenes.init ->
          Routing.init()
          Thingie.init()
          Twitter.init()
          addDomEvents()
          _update.largeWithGL()
    large: ->
    mediumWithGL: ->
      Twitter.init()
      Blog.init()
    medium: ->
      Twitter.init()
      Blog.init()
    smallWithGL: ->
      Twitter.init()
      Blog.init()
    small: ->
      Twitter.init()
      Blog.init()
    fail: ->
      alert 'Update your browser yo!'

  _update =
    largeWithGL: ->
      Animate.update()
      Events.update()
      Rendering.update()
      Thingie.update()
      Projects.update()
      _animationFrameRequest = requestAnimationFrame _update.largeWithGL
    large: ->
    mediumWithGL: ->
    medium: ->
    smallWithGL: ->
    small: ->
    fail: ->

  _kill =
    largeWithGL: ->
      Rendering.clearScene()
      $('canvas').remove()
      $('main').height '100%'
      $('#wrapper').width('100%').height '100%'
      Scenes.clear()
      $('.is-transformed').css window.transform, 'matrix(1, 0, 0, 1, 0, 0)'
      _.each Blocks, (prop, key) -> Blocks[key] = null if _.isObject(prop) and not _.isFunction(prop)
      _.each Scenes, (prop, key) -> Scenes[key] = null if _.isObject(prop) and not _.isFunction(prop)
    large: ->
    mediumWithGL: ->
    medium: ->
    smallWithGL: ->
    small: ->
    fail: ->

  _resize =
    largeWithGL: ->
      screenSize = Events.get.screenSize()
      Rendering.setRendererSize screenSize
      [width, height] = screenSize
      $('main').height(height)
      $('#wrapper').width(width).height(width)
    large: ->
    mediumWithGL: ->
    medium: ->
    smallWithGL: ->
    small: ->
    fail: ->