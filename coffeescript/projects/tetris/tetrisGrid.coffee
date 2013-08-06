class TetrisGrid
  @BLANK:
    for x in [0..21]
      for y in [0..11]
        if y in [0, 11] then -3
        else if x in [0, 21] then -2
        else 0

  @Update: (grid, tetrimino, move, func) ->
    for row in [0...tetrimino.shape[move.rotation].length]
      gridRowN = move.row - tetrimino.offset.minus + row
      gridRow = grid[gridRowN]
      for column in [0...tetrimino.shape[move.rotation][row].length]
        gridColumnN = move.column - tetrimino.offset.minus + column
        if grid[gridRowN]?[gridColumnN]?
          if func is 'ADD'
            grid[gridRowN][gridColumnN] += tetrimino.shape[move.rotation][row][column] * tetrimino.colour
          else if func is 'SUB'
            grid[gridRowN][gridColumnN] -= tetrimino.shape[move.rotation][row][column] * tetrimino.colour
    grid

  @CreateDomain = (tetrimino, domain = []) ->    
    offsetM = tetrimino.offset.minus
    offsetP = tetrimino.offset.plus
    for rotation in [0...tetrimino.shape.length]
      for row in [20..1]
        for column in [1..10]
          if TetrisGrid.ValidPosition tetrimino.shape[rotation], row, column, offsetM, offsetP
            domain.push
              rotation: rotation
              row: row
              column: column
              valid: true
    domain
    
  @ValidPosition = (shape, row, column, offM, offP, grid = TetrisGrid.BLANK) ->
    surroundingRows = grid[row - offM..row + offP]
    surroundings = (surroundingRow[column - offM..column + offP] for surroundingRow in surroundingRows)

    for row in [0...surroundings.length]
      for column in [0...surroundings[row].length]
        if shape[row][column] is 1 and surroundings[row][column] isnt 0
          return false
    return true
    
root = exports ? this
root.TetrisGrid = TetrisGrid
