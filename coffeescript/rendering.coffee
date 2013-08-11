if Modernizr.webgl
  (exports ? @).Rendering = do ->
    FIELD_OF_VIEW = 70
    ASPECT_RATIO = 16 / 9
    NEAR_Z = 0.01
    FAR_Z = 800

    SIX_AM = 6
    SIX_PM = 18

    _scene = new THREE.Scene()
    _renderer = new THREE.WebGLRenderer(antialias: yes)
    _camera = new THREE.PerspectiveCamera(FIELD_OF_VIEW, ASPECT_RATIO, NEAR_Z, FAR_Z)
    _lights = []

    _nighttime = no
    _project = no

    _initShadow = ->
      _renderer.shadowMapEnabled = yes
      _renderer.shadowCameraNear = NEAR_Z
      _renderer.shadowCameraFar = FAR_Z
      _renderer.shadowCameraFov = FIELD_OF_VIEW
      _renderer.shadowMapDarkness = 1
      _renderer.shadowMapWidth = 256
      _renderer.shadowMapHeight = 256
    
    _initCamera = ->
      _camera.position = new THREE.Vector3(960, 540, 772)
      _camera.lookAt new THREE.Vector3(960, 540, 0)

    _makeLight = (colour, position) ->
      light = if _nighttime then new THREE.SpotLight(colour, 2.5) else new THREE.DirectionalLight(colour)
      light.position = position
      light.target.position = new THREE.Vector3(960, 540, 10)
      light.castShadow = yes
      light.shadowCameraVisible = Main.debug
      _lights.push light
      _scene.add light
    
    _initLights = ->
      _lights = []
      _nighttime = new Date().getHours() < SIX_AM or new Date().getHours() > SIX_PM
      if _nighttime
        _renderer.setClearColor Colours.background.night, 1
        _makeLight Colours.light.night, new THREE.Vector3(0, 1080, 250)
        _makeLight Colours.light.night, new THREE.Vector3(1920, 1080, 250)
      else
        _renderer.setClearColor Colours.background.day, 0
        _makeLight Colours.light.day, new THREE.Vector3(-200, 1080, 700)
        _makeLight Colours.light.day, new THREE.Vector3(2120, 1080, 700)

    init = ->
      _initShadow()
      _initCamera()
      _initLights()

      $('main').append _renderer.domElement
      setRendererSize Events.get.screenSize()

      [_scene, _camera]

    setLightTarget = (position) ->
      (_.each _lights, (light) -> light.target.position = position) unless _project

    setRendererSize = (screenSize) ->
      _renderer.setSize screenSize...

    toggleDebug = ->
      _.each _scene.children, (child) ->
        if child instanceof THREE.DirectionalLight or child instanceof THREE.SpotLight
          child.shadowCameraVisible = Main.debug
        else if child.material?
          child.material.wireframe = Main.debug
        _.each child.children, (letter) ->
          if letter.material?
            letter.material.wireframe = Main.debug
  
    changeBlockColour = (oldColour, newColour) ->
      oldColour = new THREE.Color(oldColour)
      newColour = new THREE.Color(newColour)
      _.each _scene.children, (child) ->
        if child instanceof THREE.Mesh
          childColour = child.material.color
          if childColour.r is oldColour.r and childColour.g is oldColour.g and childColour.b is oldColour.b
            child.material.color = newColour
          
    changeLightColour = (newColour) ->
      _nighttime = new Date().getHours() < SIX_AM or new Date().getHours() > SIX_PM
      if _nighttime
        newColour = new THREE.Color(newColour.night)
      else
        newColour = new THREE.Color(newColour.day)
      _.each _scene.children, (child) ->
        if child instanceof THREE.DirectionalLight or child instanceof THREE.SpotLight
          child.color = newColour

    update = ->
      _renderer.render _scene, _camera unless _project
    
    initProject = ->
      _.each _lights, (light) -> light.target.position = new THREE.Vector3(960, 540, 0)
      _project = yes
    
    killProject = ->
      _project = no
      
    clearScene = ->
      children = (child for child in _scene.children)
      _.each children , (child) ->
        if child instanceof THREE.Mesh or child instanceof THREE.DirectionalLight or child instanceof THREE.SpotLight
          _scene.remove child

    init: init
    initProject: initProject
    killProject: killProject
    clearScene: clearScene
    setLightTarget: setLightTarget
    setRendererSize: setRendererSize
    toggleDebug: toggleDebug
    changeBlockColour: changeBlockColour
    changeLightColour: changeLightColour
    update: update