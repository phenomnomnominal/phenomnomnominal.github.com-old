(exports ? @).Materials = do ->
  _make = (type, colour) ->
    options =
      color: colour
      shading: THREE.SmoothShading
      overdraw: on
      wireframe: Main.debug
    new THREE["Mesh#{type}Material"](options)

  phong: (colour) ->
    _make 'Phong', colour
  lambert: (colour) ->
    _make 'Lambert', colour