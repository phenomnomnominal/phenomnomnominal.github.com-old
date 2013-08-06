class Tetrimino
  constructor: (@colour, @offset, @rotation = 0) ->
    @domain = TetrisGrid.CreateDomain this

class I extends Tetrimino
  constructor: ->
    @shape = [[[0,0,0,0],
               [1,1,1,1],
               [0,0,0,0],
               [0,0,0,0]],
              [[0,1,0,0],
               [0,1,0,0],
               [0,1,0,0],
               [0,1,0,0]]]
    super(1, plus: 2, minus: 1)

class J extends Tetrimino
  constructor: ->
    @shape = [[[0,0,0],
               [1,1,1],
               [0,0,1]],
              [[0,1,0],
               [0,1,0],
               [1,1,0]],
              [[1,0,0],
               [1,1,1],
               [0,0,0]],
              [[0,1,1],
               [0,1,0],
               [0,1,0]]]
    super(2, plus: 1, minus: 1)

class L extends Tetrimino
  constructor: ->
    @shape = [[[0,0,0],
               [1,1,1],
               [1,0,0]],
              [[1,1,0],
               [0,1,0],
               [0,1,0]],
              [[0,0,1],
               [1,1,1],
               [0,0,0]],
              [[0,1,0],
               [0,1,0],
               [0,1,1]]]
    super(3, plus: 1, minus: 1)

class O extends Tetrimino
  constructor: ->
    @shape = [[[1,1],
              [1,1]]]
    super(4, plus: 1, minus: 0)

class S extends Tetrimino
  constructor: ->
    @shape = [[[0,0,0],
               [0,1,1],
               [1,1,0]],
              [[1,0,0],
               [1,1,0],
               [0,1,0]],
              [[0,1,1],
               [1,1,0],
               [0,0,0]],
              [[0,1,0],
               [0,1,1],
               [0,0,1]]]
    super(5, plus: 1, minus: 1)

class T extends Tetrimino
  constructor: ->
    @shape = [[[0,0,0],
               [1,1,1],
               [0,1,0]],
              [[0,1,0],
               [1,1,0],
               [0,1,0]],
              [[0,1,0],
               [1,1,1],
               [0,0,0]],
              [[0,1,0],
               [0,1,1],
               [0,1,0]]]
    super(6, plus: 1, minus: 1)

class Z extends Tetrimino
  constructor: ->
    @shape = [[[0,0,0],
               [1,1,0],
               [0,1,1]],
              [[0,1,0],
               [1,1,0],
               [1,0,0]],
              [[1,1,0],
               [0,1,1],
               [0,0,0]],
              [[0,0,1],
               [0,1,1],
               [0,1,0]]]
    super(7, plus: 1, minus: 1)

class TetriminoBag
  constructor: ->
    @_ =
      bag: [new I(), new J(), new L(), new O(), new S(), new T(), new Z()]
      nextBag: []

  getNext: ->
    if @_.bag.length is 0
      @_.bag = @_.nextBag
      @_.nextBag = []
    select = Math.floor(Math.random() * @_.bag.length)
    selected = (@_.bag.splice(select, 1))[0]
    @_.nextBag.push selected
    selected

root = exports ? this
root.TetriminoBag = TetriminoBag
