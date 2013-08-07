(exports ? @).Blocks = do ->
  HD_SCREEN_WIDTH = 1920
  HD_SCREEN_HEIGHT = 1080
  NUMBER_OF_BLOCK_PER_ROW = 50
  BLOCK_Y_SPACING = HD_SCREEN_WIDTH / NUMBER_OF_BLOCK_PER_ROW
  SIZE = BLOCK_Y_SPACING * 0.7
  HALF_SIZE = SIZE / 2
  IN_POSITION = SIZE * -0.5
  OUT_POSITION = SIZE * -0.5 + 50
  GAP = BLOCK_Y_SPACING * 0.3
  HALF_GAP = GAP / 2
  OFFSET = BLOCK_Y_SPACING
  GEOMETRY = new THREE.CubeGeometry(SIZE, SIZE, SIZE)

  class BlockGroup
    constructor: (@blocks, @elements, @offDirection) ->
      if @elements?
        unless @elements.length
          @elements = [@elements]
        if @elements instanceof NodeList or @elements instanceof jQuery
          @elements = Array.prototype.slice.call @elements
      @move @offDirection, 3000

    get: (prop) ->
      _.map(@blocks, (block) -> block[prop])

    on: (eventType, handler) ->
      objects = @get 'object'
      Events.on eventType, objects, handler
      this
    off: (eventType, handler) ->
      objects = @get 'object'
      Events.off eventType, objects, handler
      this
      
    one: (eventType, handler) ->
      objects = @get 'object'
      Events.one eventType, objects, handler
      this

    animate: (options, callback) ->
      objects = @get 'object'
      Animate objects, options, callback
      Animate @elements, options if @elements 
      this

    move: (direction, amount, css = {}) ->
      if direction in ['LEFT', 'RIGHT']
        amount *= if direction is 'LEFT' then -1 else 1
        direction = 'x'
      if direction in ['UP', 'DOWN']
        amount *= if direction is 'DOWN' then -1 else 1
        direction = 'y'

      block.object.position[direction] += amount for block in @blocks

      if @elements
        # Three.js Y direction opposite to CSS Y direction
        amount *= -1 if direction is 'y'

        _transformMappings =
          'position.x': 'translateX'
          'position.y': 'translateY'
          'position.z': 'translateZ'

        css[window.transform] = "#{_transformMappings['position.' + direction]}(#{amount}px)"
        $(@elements).css css
      this

  class Block
    constructor: (@x, @y, @width = 1, @height = 1, @colour = Colours.main, @content = null) ->
      @material = Materials.phong @colour
      @object = new THREE.Mesh(GEOMETRY, @material)
      @object.position.x = @x * OFFSET + (@width * HALF_SIZE) + (@width - 1) * HALF_GAP
      @object.position.y = HD_SCREEN_HEIGHT - @y * OFFSET - (@height * HALF_SIZE) - (@height - 1) * HALF_GAP
      @object.position.z = IN_POSITION
      @object.scale.x = (SIZE * @width + GAP * (@width - 1)) / SIZE
      @object.scale.y = (SIZE * @height + GAP * (@height - 1)) / SIZE
      @object.castShadow = @object.recieveShadow = yes
      if @content?
        letterGeometry = new THREE.TextGeometry(@content, font: 'college', size: SIZE * 0.9)
        letter = new THREE.Mesh(letterGeometry, Materials.lambert Colours.white)
        letter.position = new THREE.Vector3(-SIZE * (if @content is 'I' then 0.18 else 0.3), -SIZE * 0.45, -SIZE * 0.35)
        letter.scale.z = 0.6
        @object.add letter
      Main.scene.add @object

  init = (callback) ->
    global = exports ? window
    $.getJSON 'blocks.json', (result) ->
      for own page, blockGroups of result
        global.Blocks[page] ?= {}
        for own name, blockGroup of blockGroups
          global.Blocks[page][name] ?= {}
          { x, y, blocks, width, height, colour, content } = blockGroup
          { requires, offDirection, selector, events, elementEvents } = blockGroup
          blocks = _.map blocks, (block) ->
            blockX = block.x ? x
            blockY = block.y ? y
            blockWidth = block.width ? width
            blockHeight = block.height ? height
            blockColour = block.colour ? colour
            blockContent = block.content ? content
            blockRequires = block.requires ? requires
            requiresOk = yes
            if blockRequires?
              _.each blockRequires.split(' '), (require) -> requiresOk = requiresOk and Modernizr[require]
            if requiresOk
              new Block(blockX, blockY, blockWidth, blockHeight, Colours[blockColour], blockContent)
          if blocks.length > 0
            blockGroup = new BlockGroup(blocks, $(selector), offDirection)
            for own event, handlerName of events
              if handlerName is 'menuOver'
                blockGroup.on event, UI.events[handlerName](blockGroup, name)
              else
                blockGroup.on event, UI.events[handlerName]
            for own event, handlerName of elementEvents
              $(blockGroup.elements).on event, UI.events[handlerName]
            global.Blocks[page][name] = blockGroup
      callback()
      
  makeProjectTitle = (name) ->
    titleBlocks = do ->
      BLOCK_X = _.map name, (content, i) -> 2 + i * 2
      _.map BLOCK_X , (x, i) -> new Block(x, 2, 2, 2, Colours.main, name[i])
    new BlockGroup(titleBlocks, null, 'RIGHT')

  init: init
  makeProjectTitle: makeProjectTitle
  OUT_POSITION: OUT_POSITION
  IN_POSITION: IN_POSITION