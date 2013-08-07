(exports ? @).Colours = do ->
  
  blockColours = [0xFF00FF, 0x00FFFF, 0xFFFF00, 0xFFFFFF, 
                  0x800080, 0x008080, 0x808000, 0xC0C0C0,
                  0x0000FF, 0x00FF00, 0xFF0000, 0x808080,
                  0x000080, 0x008000, 0x800000, 0x000000]
  
  lightColours = [0xFF00FF, 0x00FFFF, 0xFFFF00, 0xFFFFFF, 
                  0x800080, 0x008080, 0x808000, 0xC0C0C0,
                  0x0000FF, 0x00FF00, 0xFF0000, 0x808080,
                  0x000080, 0x008000, 0x800000, 0x000000]
  
  changeBlockColour = ->
    oldColour = Colours.main
    Colours.main = blockColours[0]
    Rendering.changeBlockColour oldColour, Colours.main
    blockColours.push(blockColours.shift())
  
  changeLightColour = ->
    Colours.light =
      day: lightColours[0]
      night: lightColours[0]
    Rendering.changeLightColour Colours.light
    lightColours.push(lightColours.shift())
  
  changeBlockColour: changeBlockColour
  changeLightColour: changeLightColour
  default: 0xDDDDFF
  main: 0x444499
  white: 0xFFFFFF
  background:
    day: 0x000000
    night: 0x060708
  light:
    day: 0xDDDDDD
    night: 0xFFFFFF