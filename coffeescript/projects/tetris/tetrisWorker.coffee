importScripts 'tetris.js', '/libraries/underscore.js'

_tetris = _chromosomeIndex = null

update = ->
  if _tetris.gameOver()
    self.postMessage 
      func: 'complete'
      score: _tetris.score
      index: _chromosomeIndex
    self.close()
  else
    _tetris.makeMove()
    self.postMessage
      func: 'move'
      tetris: _tetris
      index: _chromosomeIndex

messageHandler = (e) ->
  { func } = e.data

  switch func
    when 'evaluateFitness'
      { chromosome, index} = e.data
      { workerIndex, chromosomeIndex } = index

      _tetris = new TetrisAI(chromosome.genes)
      _chromosomeIndex = chromosomeIndex

      update()
    when 'update'
      update()

self.addEventListener 'message', messageHandler, false