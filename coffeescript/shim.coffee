do ->
  window.requestAnimFrame = do ->
    requestAnimationFrame or
    webkitRequestAnimationFrame or
    mozRequestAnimationFrame or
    oRequestAnimationFrame or
    msRequestAnimationFrame or
    (callback) -> setTimeout(callback, 1000 / 60)
  
  window.cancelAnimFrame = do ->
    cancelAnimationFrame or
    webkitCancelAnimationFrame or
    mozCancelAnimationFrame or
    oCancelAnimationFrame or
    msCancelAnimationFrame

  HTMLElement::requestFullscreen = do ->
    if HTMLElement::requestFullscreen
      HTMLElement::requestFullscreen
    else if HTMLElement::mozRequestFullScreen
      HTMLElement::mozRequestFullScreen
    else if HTMLElement::webkitRequestFullscreen
      -> @webkitRequestFullscreen Element.ALLOW_KEYBOARD_INPUT
    else if HTMLElement::webkitRequestFullScreen
      -> @webkitRequestFullScreen Element.ALLOW_KEYBOARD_INPUT

  document.exitFullscreen = do ->
    document.exitFullscreen or
    document.mozCancelFullScreen or
    document.webkitExitFullScreen or
    document.webkitCancelFullScreen

  document.isFullScreen = ->
    document.fullScreenElement? or
    document.mozFullScreenElement? or
    document.mozIsFullScreen or
    document.webkitFullScreenElement? or
    document.webkitIsFullScreen

  window.fullscreenchange = do ->
    body = document.body
    if body.onfullscreenchange?
      'fullscreenchange'
    else if body.onmozfullscreenchange?
      'mozfullscreenchange'
    else if body.onwebkitfullscreenchange?
      'webkitfullscreenchange'
    else null