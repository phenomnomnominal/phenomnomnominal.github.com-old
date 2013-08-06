Animate = do ->
  settings =
    POSITION:
      X: (value) ->
        property: 'position.x'
        value: value
        absolute: true
      Y: (value) ->
        property: 'position.y'
        value: value
        absolute: true
      Z: (value) ->
        property: 'position.z'
        value: value
        absolute: false
        nSteps: 8
    SCALE:
      X: (value) ->
        property: 'scale.x'
        value: value
        absolute: false
        nSteps: 8
      Y: (value) ->
        property: 'scale.y'
        value: value
        absolute: false
        nSteps: 8
      Z: (value) ->
        property: 'scale.z'
        value: value
        absolute: false
        nSteps: 8

  DEFAULT_MATRIX = 'matrix(1, 0, 0, 1, 0, 0)'

  getStyle = (element) ->
    if element.currentStyle
      element.currentStyle
    else if window.getComputedStyle
      document.defaultView.getComputedStyle element, null

  window.transform = do ->
    style = getStyle document.documentElement
    spellings = ['transform', 
                 '-moz-transform', 'moz-transform', 'mozTransfrom', 'MozTransform',
                 '-webkit-transform', 'webkit-transform', 'webkitTransform', 'WebkitTransform',
                 '-o-transform', 'o-transform', 'oTransform', 'OTransform',
                 '-ms-transform', 'ms-transform', 'msTransform', 'MsTransform']
    for spelling in spellings
      if {}.hasOwnProperty.call(style, spelling) or style[spelling]?
        return spelling

  getMatrixFromProperties = (properties) ->
    [style, translateX] = /translateX\((-?\d+)px\)/.exec(properties) or ['', 0]
    [style, translateY] = /translateY\((-?\d+)px\)/.exec(properties) or ['', 0]
    [style, translateZ] = /translateZ\((-?\d+)px\)/.exec(properties) or ['', 0]
    [style, scaleX] = /scaleX\((-?\d+)\)/.exec(properties) or ['', 1]
    [style, scaleY] = /scaleY\((-?\d+)\)/.exec(properties) or ['', 1]
    [style, scaleZ] = /scaleZ\((-?\d+)\)/.exec(properties) or ['', 1]
    newMatrix = [scaleX, 0, 0, 0,
                 0, scaleY, 0, 0, 
                 0, 0, scaleZ, 0,
                 translateX, translateY, translateZ, 1]
    "matrix3d(#{newMatrix.join(', ')})"

  cssMatrixDecompose = (element, property) ->
    matrix = getStyle(element).getPropertyValue window.transform
    matrix = element.style[window.transform] if matrix is 'none'
    matrix = DEFAULT_MATRIX if matrix in ['none', '']
    matrix = getMatrixFromProperties(matrix) if matrix.indexOf('matrix') is -1
    values = matrix.split(/\(|\)/)[1].split ', '
    switch property
      when 'translateX'
        if values.length is 6 then values[4] else values[12]
      when 'translateY'
        if values.length is 6 then values[5] else values[13]
      when 'translateZ'
        if values.length is 6 then 0 else values[14]
      
  cssMatrixCompose = (object, property, value) ->
    css = getStyle(object).getPropertyValue window.transform
    css = if css is 'none' then DEFAULT_MATRIX else css
    values = css.split(/\(|\)/)[1].split(', ')
    newMatrix = [values[0], values[1], 0, 0,
                 values[2], values[3], 0, 0, 
                 0,         0,         1, 0,
                 0,         0,         0, 1]
    switch property
      when 'translateX'
        newMatrix[12] = value
      when 'translateY'
        newMatrix[13] = value
      when 'translateZ'
        newMatrix[14] = value
    "matrix3d(#{newMatrix.join(', ')})"

  update = ->
    for animation in _animating
      for own property, steps of animation
        if property not in ['callback', 'object']
          if steps.length > 0
            switch property
              when 'position.x'
                animation.object.position.x = steps.shift()
              when 'position.y'
                animation.object.position.y = steps.shift()
              when 'position.z'
                animation.object.position.z = steps.shift()
              when 'scale.x'
                animation.object.scale.x = steps.shift()
              when 'scale.y'
                animation.object.scale.y = steps.shift()
              when 'scale.z'
                animation.object.scale.z = steps.shift()
              when 'translateX' or 'translateY' or 'translateZ'
                animation.object.style[window.transform] = cssMatrixCompose animation.object, property, steps.shift()
          else
            if animation.callback?
              animation.callback()
              animation.callback = null
              delete animation.callback
              animation[property] = null
              delete animation[property]

  _animating = []
  _keys = []
  
  _getOptions = (options) ->
    if not options.property
      throw Error 'ANIMATION OPTIONS ERROR: Animation property must be defined.'
    if not options.value
      throw Error 'ANIMATION OPTIONS ERROR: Animation value must be defined.'
    options.nSteps ?= 30
    options.absolute ?= false

  _transformMappings =
    'position.x': 'translateX'
    'position.y': 'translateY'
    'position.z': 'translateZ'

  animate = (object, options, callback) ->
    _getOptions options

    objects = if object instanceof NodeList or object instanceof Array then object else [object]

    for object in objects
      property = options.property
      property = _transformMappings[property] if object instanceof HTMLElement
      
      current = options.value
      switch property
        when 'position.x'
          current = object.position.x
        when 'position.y'
          current = object.position.y
        when 'position.z'
          current = object.position.z
        when 'scale.x'
          current = object.scale.x
        when 'scale.y'
          current = object.scale.y
        when 'scale.z'
          current = object.scale.z
        when 'translateX' or 'translateY' or 'translateZ'
          current = +cssMatrixDecompose object, property

      key = _keys.indexOf object
      if key is -1
        _keys.push object
        key = _keys.indexOf object

      if _animating[key]?[property]?.length > 0
        previousAnimations = _animating[key][property]
        current = previousAnimations[previousAnimations.length - 1]

      endValue = if options.absolute then current + options.value else options.value
      steps = ([0...options.nSteps]).map((i) -> current + (-i * (current - endValue) / (options.nSteps - 1)))

      _animating[key] ?= object: object
      if callback?
        _animating[key].callback = callback
        callback = null
      _animating[key][property] ?= []
      _animating[key][property] = _animating[key][property].concat steps

  animate.update = update
  for own name, setting of settings
    animate[name] = setting
  animate

(exports ? @).Animate = Animate