(exports ? @).Scenes = do ->
  _on = []
  
  _getOnAnimation = (blockGroup) ->
    switch blockGroup.offDirection
      when 'LEFT' then Animate.POSITION.X 3000
      when 'RIGHT' then Animate.POSITION.X -3000
      when 'UP' then Animate.POSITION.Y -3000
      when 'DOWN' then Animate.POSITION.Y 3000
  
  _getOffAnimation = (blockGroup) ->
    switch blockGroup.offDirection
      when 'LEFT' then Animate.POSITION.X -3000
      when 'RIGHT' then Animate.POSITION.X 3000
      when 'UP' then Animate.POSITION.Y 3000
      when 'DOWN' then Animate.POSITION.Y -3000
  
  _getBlocks = (name) ->
    firstDot = name.indexOf '.'
    [scene, name] = [name.substr(0, firstDot), name.substr(firstDot + 1)]
    if name and scene then [Blocks[scene][name]] else (blockGroup for own n, blockGroup of Blocks[name])

  init = (callback) ->
    $.getJSON 'scenes.json', (result) ->
      for own name, blockNames of result
        if not _.isFunction blockNames
          Scenes[name] ?= blockGroups: []
          for blockName in blockNames
            Scenes[name].blockGroups = Scenes[name].blockGroups.concat _getBlocks blockName
      callback()
            
  change = (scene, callback, newOn = []) ->
    if _on.length is 0
      callback()
    _.each _on, (blockGroup) ->
      if blockGroup not in Scenes[scene].blockGroups
        animation = _getOffAnimation blockGroup
        blockGroup.animate animation, callback
        callback = null
      else
        newOn.push blockGroup
    _.each Scenes[scene].blockGroups, (blockGroup) ->
      if blockGroup not in newOn
        animation = _getOnAnimation blockGroup
        blockGroup.animate animation
        newOn.push blockGroup
    _on = newOn

  init: init
  change: change