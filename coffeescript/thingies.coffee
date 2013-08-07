Thingie = do ->
  thingies = []
  _blocks = null
  
  REQUEST_ANIMATION_FRAME_FPS = 60
  frame = 0
  
  _getRandomColour = (base) ->
    r = Math.floor(Math.random() * (255 - base) + base)
    g = Math.floor(Math.random() * (255 - base) + base)
    b = Math.floor(Math.random() * (255 - base) + base)
    parseInt(r.toString(16) + g.toString(16) + b.toString(16), 16)

  if Modernizr.webgl
    thingies.push do ->
      framesPerUpdate = REQUEST_ANIMATION_FRAME_FPS / 2
      
      init: ->
        _blocks = Blocks.home.CONTENT.blocks

      update: ->
        if frame % framesPerUpdate is 0
          for block in _blocks
            block.object.material.color.setHex _getRandomColour(155)
        frame += 1
    
    if Modernizr.geolocation
      thingies.push do ->
        _world = [430, 431, 432, 433, 435, 477, 479, 481, 482, 483, 490, 491,
                  492, 494, 525, 526, 527, 528, 529, 530, 531, 533, 536, 537,
                  538, 539, 540, 541, 542, 543, 544, 545, 546, 547, 577, 578,
                  579, 580, 581, 585, 586, 587, 588, 589, 590, 591, 592, 593,
                  594, 595, 628, 629, 630, 635, 637, 638, 639, 640, 641, 642,
                  643, 644, 645, 678, 679, 680, 685, 686, 687, 688, 689, 690,   
                  691, 692, 693, 694, 695, 729, 735, 736, 737, 738, 739, 741,
                  742, 780, 781, 785, 786, 787, 788, 791, 792, 831, 832, 836,
                  837, 838, 842, 843, 845, 880, 881, 882, 883, 887, 888, 894,
                  895, 931, 932, 937, 938, 943, 944, 945, 981, 982, 987, 993,
                  995, 997, 1031, 1047, 1081]
                  
        _locationBlock = null
                  
        _getMapPosition = (position) ->
          { coords: { latitude, longitude } } = position
          
          LAT_SPAN = 150
          LAT_OFFSET = -60
          LAT_STEPS = 14
          latDivisions = ([LAT_STEPS..1]).map((i) -> (i * (LAT_SPAN / LAT_STEPS)) + LAT_OFFSET)
          LONG_SPAN = 360
          LONG_OFFSET = -180
          LONG_STEPS = 24
          longDivisions = ([1..LONG_STEPS]).map((i) -> (i * (LONG_SPAN / LONG_STEPS)) + LONG_OFFSET)

          if latitude >= LAT_OFFSET
            latDivision = LAT_SPAN / LAT_STEPS
            roundedLat = Math.ceil((latitude - LAT_OFFSET) / latDivision) * latDivision + LAT_OFFSET
            longDivision = LONG_SPAN / LONG_STEPS
            roundedLong = Math.ceil((longitude - LONG_OFFSET) / longDivision) * longDivision + LONG_OFFSET
            latIndex = latDivisions.indexOf roundedLat
            longIndex = longDivisions.indexOf roundedLong
            blockIndex = 424 + longIndex + (50 * latIndex)
            
            for block in _blocks
              if (block.x + (block.y * 50)) is blockIndex
                _locationBlock = block 
                block.object.material.color.setHex 0x44ff44
                  
        init: ->
          _blocks = Blocks.home.CONTENT.blocks
          setTimeout (-> navigator.geolocation.getCurrentPosition _getMapPosition), 1000
          for block in _blocks
            if (block.x + (block.y * 50)) in _world
              block.object.material.color.setHex 0x444499

        update: ->

    thingies.push do ->
      _snake = _food = _foodColour = _go = _direction = _score = _nextDirection = null
      _framesPerUpdate = 20
      _reduceFrames = false

      _eatFood = (nextSpot) ->
        _score += (251 - _framesPerUpdate)
        if _framesPerUpdate > 3
          _reduceFrames = yes
        _snake.push nextSpot

      _createFood = ->
        while _food in _snake
          _food = (Math.floor(Math.random() * 24) + 24) + (Math.floor(Math.random() * 14) * 50) + 400

      _getNextSpot = (spot) ->
        if _direction is 'RIGHT'
          if spot % 100 in [47, 97] then spot - 23 else spot + 1
        else if _direction is 'LEFT'
          if spot % 100 in [24, 74] then spot + 23 else spot - 1
        else if _direction is 'UP'
          if spot in [424...448] then spot + 650 else spot - 50
        else if _direction is 'DOWN'
          if spot in [1074...1098] then spot - 650 else spot + 50

      _moveSnake = ->
        _direction = _nextDirection
        nextSpot = _getNextSpot _snake[_snake.length - 1]
        if nextSpot not in _snake
          if nextSpot is _food
            _eatFood nextSpot
            _createFood()
          else
            _snake = _snake[1...]
            _snake.push nextSpot
          true
        else
          false

      _drawSnake = (block) ->
        if (block.x + (block.y * 50)) in _snake
          if _snake.indexOf((block.x + (block.y * 50))) is _snake.length - 1
            block.object.material.color.setHex 0x444499
          else
            block.object.material.color.setHex 0x222222

      _drawFood = (block) ->
        if (block.x + (block.y * 50)) is _food
          block.object.material.color.setHex _foodColour

      _reset = ->
        _snake = [875, 876, 877, 878, 879]
        _food = 885
        _foodColour = 0x44bb44
        _framesPerUpdate = 20
        _direction = 'RIGHT'
        _nextDirection = 'RIGHT'
        _score = 0
        s = [475, 476, 477, 525, 575, 576, 577, 627, 675, 676, 677]
        n = [479, 482, 529, 530, 532, 579, 581, 582, 629, 632, 679, 682]
        a = [484, 485, 486, 534, 536, 584, 585, 586, 634, 636, 684, 686]
        k = [488, 491, 538, 540, 588, 589, 638, 640, 688, 691]
        e = [493, 494, 495, 543, 593, 594, 643, 693, 694, 695]
        letters = [].concat s, n, a, k, e
        for block in _blocks
          block.object.material.color.setHex 0xddddff
          if (block.x + (block.y * 50)) in letters
            block.object.material.color.setHex 0x444499
        for block in _blocks
          _drawSnake block
          _drawFood block

      _drawGameOver = ->
        g = [475, 476, 477, 525, 575, 577, 625, 627, 675, 676, 677]
        a = [479, 480, 481, 529, 531, 579, 580, 581, 629, 631, 679, 681]
        m = [483, 487, 533, 534, 536, 537, 583, 585, 587, 633, 637, 683, 687]
        e = [489, 490, 491, 539, 589, 590, 639, 689, 690, 691]
        o = [775, 776, 777, 825, 827, 875, 877, 925, 927, 975, 976, 977]
        v = [779, 781, 829, 831, 879, 881, 929, 931, 980]
        e2 = [783, 784, 785, 833, 883, 884, 933, 983, 984, 985]
        r = [787, 788, 837, 839, 887, 888, 937, 939, 987, 989]
        letters = [].concat g, a, m, e, o, v, e2, r
        for block in _blocks
          block.object.material.color.setHex 0xddddff
          if (block.x + (block.y * 50)) in letters
            block.object.material.color.setHex 0x444499

      init: ->
        _blocks = Blocks.home.CONTENT.blocks
        _reset()

      update: ->
        if _go
          if frame % _framesPerUpdate is 0
            if _moveSnake()
              for block in _blocks
                block.object.material.color.setHex 0xddddff
                _drawSnake block
                _drawFood block
              if _reduceFrames
                _framesPerUpdate -= 1
                _reduceFrames = no
            else
              _drawGameOver()
              _go = false
              setTimeout (->
                alert "YOUR SCORE: #{_score}!"
                _reset()
              ), 40
          frame += 1

      eventHandlers:
        keydown: (e) ->
          _go = true
          switch e.keyCode
            when 37 then if _direction in ['UP', 'DOWN'] then _nextDirection = 'LEFT'
            when 38 then if _direction in ['LEFT', 'RIGHT'] then _nextDirection = 'UP'
            when 39 then if _direction in ['UP', 'DOWN'] then _nextDirection = 'RIGHT'
            when 40 then if _direction in ['LEFT', 'RIGHT'] then _nextDirection = 'DOWN'
          if e.keyCode in [37..40]
            e.preventDefault()
            false
          else
            true

  thingie = thingies[Math.floor(Math.random() * thingies.length)]
  if thingie
    do ->
      for own event, handler of thingie.eventHandlers
        $(document.body).on event, handler
      
      init: thingie.init
      update: thingie.update

(exports ? this).Thingie = Thingie