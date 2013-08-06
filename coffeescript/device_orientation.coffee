(exports ? @).DeviceOrientation = do ->
  DEVICE_ORIENTATION = 'deviceorientation'

  X_AXIS = new THREE.Vector3(1, 0, 0)
  Z_AXIS = new THREE.Vector3(0, 0, 1)
  
  piOver540 = Math.PI / 540

  _lastBeta = _lastGamma = null

  rotateAroundWorldAxis = (object, axis, radians) ->
    rotationMatrix = new THREE.Matrix4()
    rotationMatrix.makeRotationAxis axis, radians
    rotationMatrix.multiply object.matrix unless axis is X_AXIS
    object.matrix = rotationMatrix
    object.rotation.setFromRotationMatrix object.matrix

  init = ->
    if Modernizr.deviceorientation
      window.addEventListener DEVICE_ORIENTATION, (event, xTilt = 0, zTilt = 0) ->
        _.each Blocks.common.HEADER.blocks, (block) ->
          if Math.abs(_lastBeta - event.beta) > 5
            xTilt = -event.beta * piOver540
          if Math.abs(_lastGamma - event.gamma) > 5
            zTilt = event.gamma * piOver540
          rotateAroundWorldAxis block.object, X_AXIS, xTilt
          rotateAroundWorldAxis block.object, Z_AXIS, zTilt

  init: init