(exports ? @).UI = do ->
  events =
    menuOver: (blockGroup, name) -> (intersected) ->
      events.addPointer()
      blockGroup.animate Animate.POSITION.Z(Blocks.OUT_POSITION)
      blockGroup.on 'click', ((name) -> -> Routing.go(name))(name)
      blockGroup.on 'mouseout', events.menuOut(blockGroup, name)
      blockGroup.off 'mouseover'
    menuOut: (blockGroup, name) -> (intersected) ->
      if _.intersection(intersected, blockGroup.get 'object').length is 0
        events.removePointer()
        blockGroup.animate Animate.POSITION.Z(Blocks.IN_POSITION)
        blockGroup.off 'click'
        blockGroup.off 'mouseout'
        blockGroup.on 'mouseover', events.menuOver(blockGroup, name)

    addPointer: -> $(document.body).addClass 'cursor'
    removePointer: -> $(document.body).removeClass 'cursor'

    back: -> Routing.back()

    initProject: (e) ->
      projectId = $(e.target).closest('a').attr('id')
      projectName = projectId.substr 0, projectId.indexOf '-project'
      Routing.go "projects/#{projectName}"

    changeBlockColour: ->
      Colours.changeBlockColour()
    changeLightColour: ->
      Colours.changeLightColour() 
    toggleFullscreen: ->
      if document.isFullScreen() then document.exitFullscreen() else document.documentElement.requestFullscreen()
    toggleWireframe: ->
      Main.toggleDebug()

    windowResize: ->
      screenSize = Events.get.screenSize()
      Rendering.setRendererSize screenSize
      [width, height] = screenSize
      $('main').height(height)
      $('#wrapper').width(width).height(width)
      $(document.body).css 'font-size': (width / 25) * 0.85

    mousemove: ->
      [x, y] = Events.get.mousePixels()
      Rendering.setLightTarget new THREE.Vector3(x, 1080 - y, 10)

  events: events