(exports ? @).EasterEggs = do ->
  
  daybreak = ->
    $(document.body).append $('<audio>', 
      src: '/audio/daybreak.mp3'
      autoplay: true
    )
    
  KONAMI_KEYS = [38, 38, 40, 40, 37, 39, 37, 39, 66, 65]
  do ->
    pressedKeys = []
    $(document.body).on 'keyup', (e) ->
      if e.keyCode is KONAMI_KEYS[pressedKeys.length]
        pressedKeys.push e.keyCode
      else
        pressedKeys = []
      if pressedKeys.length is KONAMI_KEYS.length
        daybreak()
        pressedKeys = []