(exports ? @).Events = do ->
  _projector = new THREE.Projector()
  _scene = null
  _camera = null

  _previousIntersected = []
  _previousObjects = []
  _intersected = []
  _objects = []
  _previousMouseX = _previousMouseY = 0
  _width = _height = null
  _mouseX = _mouseY = 0
  _mousePixelsX = _mousePixelsY = 0

  _activeEvents = {}
  _eventMappings = {}

  _getWidthAndHeight = (container) ->
    if container.height() >= container.width() * 9 / 16
      _height = container.height()
      _width = _height * 16 / 9
      $('main').css 'overflow-x': 'scroll', 'overflow-y': 'hidden'
    else
      _width = container.width()
      _height = _width * 9 / 16
  _getWidthAndHeight($(window))

  _mousedown = false
  _mouseup = false
  _click = false
  $(document.body).mousemove (e) ->
    _mouseX = 2 * ((e.clientX + $('main').scrollLeft()) / _width) - 1
    _mouseY = -2 * ((e.clientY + $(document).scrollTop()) / _height) + 1
    _mousePixelsX = e.clientX
    _mousePixelsY = e.clientY
  $(document.body).click (e) ->
    _click = true
  $(document.body).mousedown (e) ->
    _mousedown = true
    _mouseup = false
  $(document.body).mouseup (e) ->
    _mousedown = false
    _mouseup = true

  $(window).resize (e) ->
    _getWidthAndHeight($(window))

  _runEvents = ->
    _.each _activeEvents, (objects, event) ->
      _.each objects, (object) ->
        if _eventMappings[event]?[object.id]?
          _.each _eventMappings[event][object.id], (handler) ->
            handler _objects

  init = (scene, camera) ->
    _scene = scene
    _camera = camera

  get =
    mouse: -> [_mouseX, _mouseY]
    mousePixels: -> [_mousePixelsX, _mousePixelsY]
    screenSize: -> [_width, _height]

  update = ->
    _activeEvents = {}
    _previousIntersected = _intersected

    vecOrigin = new THREE.Vector3(_mouseX, _mouseY, -1)
    vecTarget = new THREE.Vector3(_mouseX, _mouseY, 1)

    _projector.unprojectVector vecOrigin, _camera
    _projector.unprojectVector vecTarget, _camera

    vecTarget.sub(vecOrigin).normalize()
    raycaster = new THREE.Raycaster(vecOrigin, vecTarget)
    _intersected = raycaster.intersectObjects _scene.children

    _objects = (intersection.object for intersection in _intersected)
    _previousObjects = (previousIntersection.object for previousIntersection in _previousIntersected)

    _activeEvents.mouseover = _.difference _objects, _previousObjects
    _activeEvents.mouseout = _.difference _previousObjects, _objects
    if _previousMouseX isnt _mouseX and _previousMouseY isnt _mouseY
      _activeEvents.mousemove = _.intersection _objects, _previousObjects

    if _objects.length > 0
      if _mousedown
        _activeEvents.mousedown = _objects
        _mousedown = false
      if _mouseup
        _activeEvents.mouseup = _objects
        _mouseup = false
      if _click
        _activeEvents.click = _objects
        _click = false

    [_previousMouseX, _previousMouseY] = [_mouseX, _mouseY]
    _runEvents()

  addEventListener = (event, objects, handler) ->
    arrObjects = if not _.isArray objects then [objects] else objects
    _.each arrObjects, (object) ->
      _eventMappings[event] ?= {}
      _eventMappings[event][object.id] ?= []
      _eventMappings[event][object.id].push handler
    objects

  removeEventListener = (event, objects, handler) ->
    arrObjects = if not _.isArray objects then [objects] else objects
    for object in arrObjects 
      hasEvents = _eventMappings[event]?[object.id]?
      objectEvents = _eventMappings[event][object.id]
      if objectEvents
        if hasEvents? and (index = objectEvents.indexOf(handler)) > -1
          objectEvents.splice index, 1
        else if hasEvents? and not handler?
          _eventMappings[event][object.id] = []
    objects

  init: init
  get: get
  update: update
  addEventListener: addEventListener
  on: addEventListener
  removeEventListener: removeEventListener
  off: removeEventListener