class TetrisAI
  @BLOCKADE_WEIGHT = 0
  @HEIGHT_WEIGHT = 0
  @LOSE_WEIGHT = 0
  @HOLES_WEIGHT = 0
  @LINE_CLEAR_WEIGHT = 0
  @TOUCH_BLOCK_WEIGHT = 0
  @TOUCH_FLOOR_WEIGHT = 0
  @TOUCH_WALL_WEIGHT = 0
  
  @ScoreWeights: (weights) ->
    @BLOCKADE_WEIGHT = weights[0]
    @HEIGHT_WEIGHT = weights[1]
    @LOSE_WEIGHT = weights[2]
    @HOLES_WEIGHT = weights[3]
    @LINE_CLEAR_WEIGHT = weights[4]
    @TOUCH_BLOCK_WEIGHT = weights[5]
    @TOUCH_FLOOR_WEIGHT = weights[6]
    @TOUCH_WALL_WEIGHT = weights[7]
  
  constructor: (weights, workers) ->
    TetrisAI.ScoreWeights weights
    @_ =
      bag: new TetriminoBag()
      tetriminoes:
        current: null
        next: null
    @_.tetriminoes.current = @_.bag.getNext()
    @_.tetriminoes.next = @_.bag.getNext()
    
    @grid = 
      for x in [0..21]
        for y in [0..11]
          if y in [0, 11] then -3
          else if x in [0, 21] then -2
          else 0
    @level = 0
    @lines = 0
    @moves = 0
    @score = 0
    
  makeMove: ->
    [bestNextMove, bestScore] = getBestNextMove @grid, @_.tetriminoes
    if bestNextMove
      @grid = TetrisGrid.Update @grid, @_.tetriminoes.current, bestNextMove, 'ADD'
      
      [@grid, clearedLines] = clearLines @grid
      @lines += clearedLines.length
      @level = setLevel @lines
      @score += setScore clearedLines.length, @level
      
      @_.tetriminoes.current = @_.tetriminoes.next
      @_.tetriminoes.next = @_.bag.getNext()
      
      @moves++
      bestScore
    else
      @noMoves = true
    
  gameOver: ->
    _.any(@grid[1][1..10], ((val) -> val > 0)) or @noMoves

  getBestNextMove = (grid, tetriminoes) ->
    { current, next } = tetriminoes
    possibleNextMoves = getPossibleMoves grid, current
    possibleFollowingMoves = getPossibleMoves grid, next
    
    bestScore = -Infinity
    bestMove = null
    for nextMove in possibleNextMoves
      if nextMove.valid
        if movePathExists grid, current, nextMove
          grid = TetrisGrid.Update grid, current, nextMove, 'ADD'
        
          firstTouchDownScore = score.touchDown grid, current, nextMove
          if firstTouchDownScore > 0
            firstMoveScore =
              blockades: score.blockades grid, current, nextMove
              height: score.height current, nextMove
              holes: score.holes grid, current, nextMove
              lines: score.lines grid
              touchDown: firstTouchDownScore
              touchSide: score.touchSide grid, current, nextMove
        
            totalFirstMoveScore = 0
            totalFirstMoveScore += value for own key, value of firstMoveScore
      
            if firstMoveScore.lines > 0
              [grid, clearedLines] = clearLines grid
          
            possibleFollowingMoves = _.map possibleFollowingMoves, ((move) ->
              { rotation, row, column } = move
              { minus, plus } = next.offset
              move.valid = TetrisGrid.ValidPosition next.shape[rotation], row, column, minus, plus, grid
              move
            )
      
            for followingMove in possibleFollowingMoves
              if followingMove.valid
                if movePathExists grid, next, followingMove
                  grid = TetrisGrid.Update grid, next, followingMove, 'ADD'
        
                  secondTouchDownScore = score.touchDown grid, next, followingMove
                  if secondTouchDownScore > 0
                    secondMoveScore =
                      blockades: score.blockades grid, next, followingMove
                      height: score.height next, followingMove
                      holes: score.holes grid, next, followingMove
                      lines: score.lines grid
                      touchDown: secondTouchDownScore
                      touchSide: score.touchSide grid, next, followingMove
            
                    totalSecondMoveScore = 0
                    totalSecondMoveScore += value for own key, value of secondMoveScore
                
                    if totalFirstMoveScore + totalSecondMoveScore > bestScore
                      bestScore = totalFirstMoveScore + totalSecondMoveScore
                      bestScoreObj = firstMoveScore
                      bestMove = nextMove

                  grid = TetrisGrid.Update grid, next, followingMove, 'SUB'

            if firstMoveScore.lines > 0
              grid = replaceLines grid, clearedLines

          grid = TetrisGrid.Update grid, current, nextMove, 'SUB'
    [bestMove, bestScoreObj]
    
  getPossibleMoves = (grid, tetrimino) ->
    highestRow = getHighestRow grid
    possibleMoves = _.filter tetrimino.domain, ((move) -> move.row >= highestRow)
    possibleMoves = _.map possibleMoves, ((move) ->
      { rotation, row, column } = move
      { minus, plus } = tetrimino.offset
      move.valid = TetrisGrid.ValidPosition tetrimino.shape[rotation], row, column, minus, plus, grid
      move
    )

  getHighestRow = (grid) ->
    for row in [1..20]
      for column in [1..10]
        if grid[row][column] > 0
          return Math.max 1, row - 3
    return 17
    
  movePathExists = (grid, tetrimino, move) ->
    shape = tetrimino.shape[move.rotation]
    rowLength = shape[0].length
    for column in [0...rowLength]
      for row in [0...shape.length]
        if shape[row][column] is 1
          realRow = move.row - tetrimino.offset.minus + row
          realColumn = move.column - tetrimino.offset.minus + column
          up = (grid[upRow][realColumn] for upRow in [1...realRow])
          for block in up
            if block > 0
              return false
          break
    return true

  score = 
    blockades: (grid, tetrimino, move) ->
      blockades = 0
      shape = tetrimino.shape[move.rotation]
      rowLength = shape[0].length
      for column in [0...rowLength]
        if _.any (shape[row][column] for row in [0...shape.length]), ((val) -> val is 1)
          realRow = move.row - tetrimino.offset.minus
          realColumn = move.column - tetrimino.offset.minus + column
          up = (grid[row][realColumn] for row in [21..realRow])
          foundFirstHole = false
          for block in up 
            if block is 0
              foundFirstHole = true
            else if foundFirstHole and block > 0
              blockades++
      TetrisAI.BLOCKADE_WEIGHT * blockades
    height: (tetrimino, move) ->
      height = 0
      lose = 0
      rotation = tetrimino.shape[move.rotation]
      for row in [0...rotation.length]
        for column in [0...rotation[row].length]
          realRow = move.row - tetrimino.offset.minus + row
          if realRow is 1
            lose = 1
          height += rotation[row][column] * (21 - realRow)
      TetrisAI.HEIGHT_WEIGHT * height + TetrisAI.LOSE_WEIGHT * lose
    holes: (grid, tetrimino, move) ->
      holes = 0
      shape = tetrimino.shape[move.rotation]
      rowLength = shape[0].length
      for column in [0...rowLength]
        if _.any (shape[row][column] for row in [0...shape.length]), ((val) -> val is 1)
          realRow = move.row - tetrimino.offset.minus
          realColumn = move.column - tetrimino.offset.minus + column
          down = (grid[row][realColumn] for row in [realRow..21])
          foundFirstBlock = false
          for block in down
            if block > 0
              foundFirstBlock = true
            else if foundFirstBlock and block is 0
              holes++
      TetrisAI.HOLES_WEIGHT * holes
    lines: (grid) ->
      lines = 0
      for row in [20..1]
        if _.all grid[row][1..10], ((val) -> val > 0)
          lines++
      TetrisAI.LINE_CLEAR_WEIGHT * lines
    touchDown: (grid, tetrimino, move) ->
      touch =
        block: 0
        floor: 0
      shape = tetrimino.shape[move.rotation]
      for row in [0...shape.length]
        for column in [0...shape[row].length]
          if shape[row][column] is 1
            realRow = move.row - tetrimino.offset.minus + row
            realColumn = move.column - tetrimino.offset.minus + column
            if realRow is 20
              touch.floor++
            [offRow, offCol] = [1, 0]
            gridBlock = grid[realRow + offRow]?[realColumn + offCol] ? 0
            shapeBlock = shape[row + offRow]?[column + offCol] ? 0
            if gridBlock > 0 and shapeBlock isnt 1
              touch.block++
      TetrisAI.TOUCH_BLOCK_WEIGHT * touch.block + TetrisAI.TOUCH_FLOOR_WEIGHT * touch.floor
    touchSide: (grid, tetrimino, move) ->
      touch =
        block: 0
        wall: 0
      shape = tetrimino.shape[move.rotation]
      for row in [0...shape.length]
        for column in [0...shape[row].length]
          if shape[row][column] is 1
            realRow = move.row - tetrimino.offset.minus + row
            realColumn = move.column - tetrimino.offset.minus + column
            if realColumn in [1, 10]
              touch.wall++
            for [offRow, offCol] in [[0, 1], [1, 0]]
              gridBlock = grid[realRow + offRow]?[realColumn + offCol] ? 0
              shapeBlock = shape[row + offRow]?[column + offCol] ? 0
              if gridBlock > 0 and shapeBlock isnt 1
                touch.block++
      TetrisAI.TOUCH_BLOCK_WEIGHT * touch.block + TetrisAI.TOUCH_WALL_WEIGHT * touch.wall

  clearLines = (grid) ->
    clearedLines = []
    for row in [20..1]
      if _.all grid[row + clearedLines.length][1..10], ((val) -> val > 0)
        clearedLine = row: row, line: grid[row + clearedLines.length]
        for rowUp in [row + clearedLines.length...1]
          grid[rowUp] = grid[rowUp - 1]
        grid[1] = [-3,0,0,0,0,0,0,0,0,0,0,-3]
        clearedLines.push clearedLine
    [grid, clearedLines]

  replaceLines = (grid, clearedLines) ->
    for clearedLine in clearedLines
      for rowDown in [1..clearedLine.row - 1]
        grid[rowDown] = grid[rowDown + 1]
      grid[clearedLine.row] = clearedLine.line
    grid
    
  setLevel = (lines) ->
    Math.floor(Math.min(lines, 100) / 10)
    
  setScore = (linesCleared, level) ->
    scores = [0, 40, 100, 300, 1200]
    scores[linesCleared] * (level + 1) + 20
    
root = exports ? this
root.TetrisAI = TetrisAI