$ ->
  if Modernizr.webgl
    addDomEvents = ->
      document.body.addEventListener 'mousemove', UI.events.mousemove
      document.body.addEventListener fullscreenchange, UI.events.windowResize
      $(window).on 'resize', UI.events.windowResize
      $(window).trigger 'resize'

    [Main.scene, Main.camera] = Rendering.init()
    Events.init(Main.scene, Main.camera)
    Blocks.init ->
      Blog.init()
      CV.init()
      DeviceOrientation.init()
      Scenes.init ->
        Routing.init()
        Thingie.init()
        Twitter.init()
        addDomEvents()

        Main.update()

(exports ? @).Main = do ->
  toggleDebug = ->
    Main.debug = not Main.debug
    Rendering.toggleDebug()

  update = ->
    Animate.update()
    Events.update()
    Rendering.update()
    Thingie.update()
    Projects.update()
    requestAnimationFrame update

  debug: no
  toggleDebug: toggleDebug
  update: update