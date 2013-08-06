(exports ? @).tetris = do ->
  COLOURS = [null, '#000000', '#222222', '#444444', '#666666', '#888888', '#AAAAAA', '#CCCCCC']

  $CONTAINER = CANVAS = GAMES = CONTEXT = GAME_WIDTH = GAME_HEIGHT = CELL_PADDING = CELL_SIZE = INFO_HEIGHT = null
  POPULATION_SIZE = 32
  GAMES_PER_ROW = 12
  ROWS = 3
  
  best = null
  toUpdate = []

  _resize = ->
    CANVAS.width = $CONTAINER.innerWidth() - 50
    CANVAS.height = $CONTAINER.innerHeight() - 50
    GAME_WIDTH = CANVAS.width / GAMES_PER_ROW
    CELL_PADDING = 10
    CELL_SIZE = (GAME_WIDTH - CELL_PADDING * 2) / 10
    GAME_HEIGHT = CELL_SIZE * 20
    GAME_HEIGHT += ((CANVAS.height - (ROWS * GAME_HEIGHT)) / ROWS)
    
  _move = (tetris, index) ->
    if best is null
      best = tetris
      best.index = index + 1
      best.generation = Genie.getGeneration()
    else if tetris.score > best.score
      best = tetris
      best.index = index + 1
      best.generation = Genie.getGeneration()
    toUpdate.push { tetris, index }

  init = ($container) ->
    $CONTAINER = $container
    $CONTAINER.empty()
    CANVAS = $('<canvas>').get 0
    $CONTAINER.append CANVAS
    CONTEXT = CANVAS.getContext('2d')
    
    $(window).resize _resize

    if WorkerBench.workersAvailable() and false
      genieInit = ->
        _resize()
        Genie.init
          workerMessageHandler: (e) ->
            switch (e.data.func)
              when 'move'
                _move e.data.tetris, e.data.index
                e.target.postMessage func: 'update'
              when 'complete'
                Genie.reportFitness e.data.score, e.data.index
          workerScriptPath: '/javascript/tetrisWorker.js'
          useWorkers: WorkerBench.result()
          logging: true
          numberOfGenes: 8
        Genie.run()
      
      WorkerBench.init onComplete: genieInit
      WorkerBench.start()
    else
      _resize()
      Genie.init
        evaluateFitness: (chromosome, chromosomeIndex) ->
          tetris = new TetrisAI(chromosome.genes)
          update = ->
            debugger
            if tetris.gameOver()
              Genie.reportFitness tetris.score, chromosomeIndex
            else
              _move tetris, chromosomeIndex
              tetris.makeMove()
              requestAnimFrame update
          update()
        logging: true
        numberOfGenes: 8
        useWorkers: false
      Genie.run()

  update = ->
    for game in toUpdate
      xIndex = game.index % GAMES_PER_ROW
      yIndex = Math.floor(game.index / GAMES_PER_ROW)
      CONTEXT.clearRect xIndex * GAME_WIDTH + CELL_PADDING, yIndex * GAME_HEIGHT + CELL_PADDING, GAME_WIDTH, GAME_HEIGHT
      CONTEXT.fillStyle = 'rgba(0, 0, 0, 0.1)'
      CONTEXT.fillRect xIndex * GAME_WIDTH + CELL_PADDING, yIndex * GAME_HEIGHT + CELL_PADDING, CELL_SIZE * 10, CELL_SIZE * 20
      if game.tetris?
        for x in [0...10]
          for y in [0...20]
            value = game.tetris.grid[y + 1][x + 1]
            unless value in [0, 8, 9, -2, -3]
              CONTEXT.fillStyle = COLOURS[value]
              fillX = x * CELL_SIZE + 1 + xIndex * GAME_WIDTH + CELL_PADDING
              fillY = y * CELL_SIZE + 1 + yIndex * GAME_HEIGHT + CELL_PADDING
              CONTEXT.fillRect fillX, fillY, CELL_SIZE - 2, CELL_SIZE - 2
        game.update = false
        CONTEXT.font = 'bold 30px College'
        CONTEXT.fillStyle = '#444499'
        CONTEXT.fillText game.index + 1, xIndex * GAME_WIDTH + CELL_PADDING + 5, yIndex * GAME_HEIGHT + CELL_PADDING + 25
        CONTEXT.font = 'bold 15px College'
        CONTEXT.fillStyle = '#44BB44'
        CONTEXT.fillText game.tetris.score, xIndex * GAME_WIDTH + CELL_PADDING + 5, yIndex * GAME_HEIGHT + CELL_PADDING + 50
    toUpdate = []
    if best
      CONTEXT.font = 'bold 30px College'
      CONTEXT.clearRect GAME_WIDTH * 8, (GAME_HEIGHT + INFO_HEIGHT) * 2, 400, 150
      CONTEXT.fillStyle = '#444499'
      CONTEXT.fillText 'BEST SCORE: ', GAME_WIDTH * 8 + 10, GAME_HEIGHT * 2 + 30
      CONTEXT.fillText 'GENERATION: ', GAME_WIDTH * 8 + 10, GAME_HEIGHT * 2 + 70
      CONTEXT.fillText 'CANDIDATE: ', GAME_WIDTH * 8 + 10, GAME_HEIGHT * 2 + 110
      CONTEXT.fillStyle = '#449944'
      CONTEXT.fillText best?.score or '', GAME_WIDTH * 8 + 200, GAME_HEIGHT * 2 + 30
      CONTEXT.fillText best?.generation or '', GAME_WIDTH * 8 + 200, GAME_HEIGHT * 2 + 70
      CONTEXT.fillText best?.index or '', GAME_WIDTH * 8 + 200, GAME_HEIGHT * 2 + 110

  kill = ->
    Genie.kill()

  init: init
  update: update
  kill: kill