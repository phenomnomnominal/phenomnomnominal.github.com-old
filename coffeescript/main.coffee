$ -> $(window).trigger 'resize'

(exports ? @).Main = do ->
  toggleDebug = ->
    Main.debug = not Main.debug
    Rendering.toggleDebug()

  debug: no
  toggleDebug: toggleDebug