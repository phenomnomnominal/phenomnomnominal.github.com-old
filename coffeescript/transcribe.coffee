audioFile = null

channels = []
drawAbsolute = false
drawEnvelope = false

noteon = false
noteoff = false
tune = false

audioContext = null

threshold =
  on: null
  off: null
  yOn: null
  drawYOn: null
  yOff: null
  drawYOff: null
  drawY: null

zoom =
  vert: 1
  maxVert: 0
  hor: 1
  maxHor: 0

scroll =
  x: 0
  dx: 0
  y: 0
  dy: 0

canvasWidth = $('canvas:first').width()
canvasHeight = $('canvas:first').height()

create =
  canvas: (n) ->
    for c in [0...n]
      $('body').append $ '<canvas>'
        unselectable: 'on'
    $('body').promise().done ->
      $(window).trigger 'resize'

    getThreshold = (e) ->
      if noteon or noteoff
        $canvas = $(this)
        y = null
        val = null
        $('canvas').each (i, el) ->
          if el is $canvas[0]
            y = (e.pageY - $canvas.position().top)
            centre = canvasHeight / 2
            val  = -((y - centre - scroll.y) * channels[i].max) / (centre * zoom.vert)
            threshold.drawY = y
        resetThresholdButtons = ->
          $('.button').removeClass 'click'
          $('canvas').unbind 'click'
          noteon = false
          noteoff = false
          threshold.drawY = null
          #draw()
        if noteon
          $(this).unbind 'click'
          $(this).click ->
            threshold.on = val
            threshold.yOn = threshold.drawY
            threshold.drawYOn = threshold.yOn
            resetThresholdButtons()
            if threshold.on and threshold.off
              getPitches selectNotes()
              
        if noteoff
          $(this).unbind 'click'
          $(this).click ->
            threshold.off = val
            threshold.yOff = threshold.drawY
            threshold.drawYOff = threshold.yOff
            resetThresholdButtons()
            if threshold.on and threshold.off
              getPitches selectNotes()
        #draw()

    $('canvas').mousemove getThreshold
    $('canvas').mousedown (downE) ->
      down =
        x: scroll.x
        y: scroll.y
      prev =
        x: null
        y: null
      $('canvas').unbind 'mousemove'
      $('canvas').mousemove (moveE) ->
        dx = downE.pageX - moveE.pageX
        dy = downE.pageY - moveE.pageY

        scroll.x = Math.min down.x - dx, 0
        scroll.x = Math.max scroll.x, -((canvasWidth * zoom.hor) - canvasWidth)
        scroll.y = Math.min down.y - dy, (((canvasHeight / 2) * zoom.vert) - (canvasHeight / 2))
        scroll.y = Math.max scroll.y, -(((canvasHeight / 2) * zoom.vert) - (canvasHeight / 2))

        if not prev.x? then prev.x = downE.pageX
        if not prev.y? then prev.y = downE.pageY
        if scroll.x isnt 0 or scroll.y isnt 0
          scroll.dx = prev.x - moveE.pageX
          scroll.dy = prev.y - moveE.pageY
        else
          scroll.dx = 0
          scroll.dy = 0
        prev.x = moveE.pageX
        prev.y = moveE.pageY
        update.threshold.scroll()
        #draw()
    $('canvas').mouseup ->
      $('canvas').unbind 'mousemove'
      $('canvas').mousemove getThreshold

  ui: ->
    vertZoomDiv = $ '<div>'
      class: 'container left'
      unselectable: 'on'
    zoomVert = $ '<div>',
      class: 'ui slide left'
      html: '&uarr;<br/><br/>z<br/>o<br/>o<br/>m<br/><br/>&darr;'
      unselectable: 'on'
    vertZoomDiv.append zoomVert
    zoomVert.css bottom: '0px', position: 'absolute'
    $(zoomVert).draggable
      containment: '.container.left'
      drag: ->
        update.zoom $(this), 'VERT'
        update.scroll()
        update.threshold.zoom()
        #draw()
      stop: ->
        $(this).css
          top: "auto"
          bottom: "#{100 - (100 * ($(this).position().top + $(this).outerHeight(true))) / $(window).height()}%"
    horZoomDiv = $ '<div>'
      class: 'container bottom'
      unselectable: 'on'
    zoomHor = $ '<div>',
      class: 'ui slide bottom'
      html: '&larr; z o o m &rarr;'
      unselectable: 'on'
    horZoomDiv.append zoomHor
    zoomHor.css left: '0px', position: 'absolute'
    $(zoomHor).draggable
      containment: '.container.bottom'
      drag: ->
        update.zoom $(this), 'HOR'
        update.scroll()
        #draw()
      stop: ->
        $(this).css
          left: "auto"
          right: "#{100 - (100 * ($(this).position().left + $(this).outerWidth(true))) / $(window).width()}%"
    topUI = $ '<ul>'
      class: 'container top'
    absolute = $ '<li>',
      class: 'ui switch top'
      unselectable: 'on'
      text: 'absolute value'
      click: ->
        $('.button').not(this).removeClass 'click'
        $('.switch').not(this).removeClass 'click'
        $(this).toggleClass 'click'
        drawAbsolute = not drawAbsolute
        drawEnvelope = false
        #draw()
    envelope = $ '<li>',
      class: 'ui switch top'
      unselectable: 'on'
      text: 'average envelope'
      click: ->
        $('.button').not(this).removeClass 'click'
        $('.switch').not(this).removeClass 'click'
        $(this).toggleClass 'click'
        drawEnvelope = not drawEnvelope
        drawAbsolute = false
        #draw()
    noteonThres = $ '<li>',
      class: 'ui button top'
      unselectable: 'on'
      text: 'note-on threshold'
      click: ->
        $('.button').not(this).removeClass 'click'
        $(this).toggleClass 'click'
        $('canvas').unbind 'click'
        threshold.drawY = null
        noteon = not noteon
        noteoff = false
        tune = false
        #draw()
    noteoffThres = $ '<li>',
      class: 'ui button top'
      unselectable: 'on'
      text: 'note-off threshold'
      click: ->
        $('.button').not(this).removeClass 'click'
        $(this).toggleClass 'click'
        $('canvas').unbind 'click'
        threshold.drawY = null
        noteon = false
        noteoff = not noteoff
        tune = false
        #draw()
    chromatic = $ '<li>',
      class: 'ui button top'
      unselectable: 'on'
      text: 'chromatic tuner'
      click: ->
        $('.button').not(this).removeClass 'click'
        $(this).toggleClass 'click'
        $('canvas').unbind 'click'
        threshold.drawY = null
        noteon = false
        noteoff = false
        tune = true
        tuner()
    topUI.append absolute, envelope, noteonThres, noteoffThres, chromatic
    $('body').append vertZoomDiv, horZoomDiv, topUI

draw = ->
  width = canvasWidth
  height = canvasHeight
  samples = audioFile.buffer.length
  samplesPerPixel = (samples / width) / zoom.hor
  sampleShift = -Math.floor((samplesPerPixel) * scroll.x)
  dx = width / samples

  for c in [0...channels.length]
    centre = height / 2
    if drawAbsolute
      centre *= 2
      
    context = $('canvas')[c].getContext '2d'
    context.fillStyle = '#111'
    context.fillRect 0, 0, width, height
    context.lineWidth = 0.5
    
    channel = channels[c].normalise
    if drawAbsolute
      channel = channels[c].absolute
    if drawEnvelope
      channel = channels[c].envelope
      
    startS = Math.max(sampleShift, 0)
    endS = Math.min((samples / zoom.hor) + sampleShift, samples)
    step = Math.max(Math.floor(samplesPerPixel), 1)
    
    context.strokeStyle = '#EEE'
    context.beginPath()
    context.moveTo 0 + scroll.x, centre + scroll.y

    note = false
    for s in [startS...endS] by step
      context.strokeStyle = '#EEE'
      x = Math.floor (dx * s) * zoom.hor + scroll.x
      y = Math.floor centre - ((channel[s] / channels[c].max) * zoom.vert) * centre + scroll.y

      if threshold.on and threshold.off
        if channel[s] > threshold.on or note
          note = true
          context.strokeStyle = '#FF0'
        if note and channel[s] < threshold.off
          note = false
          context.strokeStyle = '#EEE'
      if samplesPerPixel < 0.2
        context.fillStyle = '#00F'
        context.fillRect x - 2.5, y - 2.5, 5, 5
      context.lineTo x, y
      context.closePath()
      context.stroke()
      context.beginPath()
      context.moveTo x, y
    context.lineTo x + 10 - scroll.x, centre + scroll.y
    context.lineTo 0 + scroll.x, centre + scroll.y
    context.closePath()
    context.stroke()
    line = (y, colour) ->
      context.strokeStyle = colour
      context.beginPath()
      context.moveTo 0, y
      context.lineTo canvasWidth, y
      context.closePath()
      context.stroke()
    if threshold.on?
      colour = '#08F'
      if noteon
        colour = '#AAF'
      line threshold.drawYOn, colour
    if threshold.off?
      colour = '#F0F'
      if noteoff
        colour = '#FAF'
      line threshold.drawYOff, colour
    if threshold.drawY?
      if noteon
        colour = '#08F'
      else if noteoff
        colour = '#F0F'
      line threshold.drawY, colour

getPitches = (notes) ->
  roundUpPow2 = (n) ->
    n--
    n |= n >> 1
    n |= n >> 2
    n |= n >> 4
    n |= n >> 8
    n |= n >> 16
    n++
  
  for note in notes
    length = note.off - note.on
    rounded = roundUpPow2(length) + 1
    fft = new FFT(rounded, audioFile.buffer.sampleRate / 4)
    audio = channels[1].audio.subarray(note.on, note.on + rounded)
    for s in [0...audio.length]
      audio[s] *= WindowFunction.Hamming audio.length, s
    downSamples = []
    for s in [0...audio.length] by 4
      audio[s / 4] = audio[s]
    fft.forward(audio)
    max = _.reduce fft.spectrum, ((max, next) ->
      if Math.abs(next) > max then Math.abs(next) else max), 0
    for f in [0...fft.spectrum.length]
      if fft.spectrum[f] is max
        console.log f
  return

selectNotes = ->
  notes = []
  note = null
  playing = false
  channel = channels[1].envelope
  for s in [0...channel.length]
    if channel[s] >= threshold.on and not playing
      playing = true
      note = on: s
    if playing and channel[s] < threshold.off
      playing = false
      if note.on?
        note.off = s
        notes.push note
        note = null
  notes
      
transform =
  absolute: (channel) ->
    (Math.abs(s) for s in channel.audio)

  envelope: (channel) ->
    averageEnv = (s for s in channel.audio)
    windowLength = 256
    runningSum = _.reduce channel.audio.subarray(0, windowLength), ((sum, next) -> sum + Math.abs(next)), 0
    for k in [windowLength...averageEnv.length]
      if k isnt windowLength
        runningSum -= Math.abs(channel.audio[k - windowLength - 1])
        runningSum += Math.abs(channel.audio[k + windowLength])    
      averageEnv[k] = runningSum / windowLength
    averageEnv

  normalise: (channel) ->
    channel.max = _.reduce channel.audio, ((max, next) ->
      if Math.abs(next) > max then Math.abs(next) else max), 0
    channel.min = _.reduce channel.audio, ((min, next) ->
      if Math.abs(next) < min and next isnt 0 then Math.abs(next) else min), 1
    channel.normalise = ((s / channel.max) for s in channel.audio)

update =
  zoom: ($el, dir) ->
    if dir is 'VERT'
      center = ($el.position().top * 100) / ($(window).height() - $el.outerHeight(true))
      zoom.vert = (((100 - center) * zoom.maxVert) / 100) + 1
    if dir is 'HOR'
      center = ($el.position().left * 100) / ($(window).width() - $el.outerWidth(true))
      zoom.hor = 1 + (zoom.maxHor - 1) * (((100 / Math.max((100 - center), 1)) - 1) / 100)

  scroll: ->
    scroll.y = Math.min scroll.y, (((canvasHeight / 2) * zoom.vert) - (canvasHeight / 2))
    scroll.y = Math.max scroll.y, -(((canvasHeight / 2) * zoom.vert) - (canvasHeight / 2))
    scroll.x = Math.max scroll.x, -((canvasWidth * zoom.hor) - canvasWidth)

  threshold:
    zoom: ->
      scaleY = (y) ->
        (canvasHeight / 2) - (((canvasHeight / 2)  - y) * zoom.vert) + scroll.y
      if threshold.yOff? then threshold.drawYOff = scaleY(threshold.yOff)
      if threshold.yOn? then threshold.drawYOn = scaleY(threshold.yOn)
    scroll: ->
      if threshold.yOff? then threshold.drawYOff = threshold.drawYOff - scroll.dy
      if threshold.yOn? then threshold.drawYOn = threshold.drawYOn - scroll.dy

tuner = ->
  navigator.getUserMedia || (navigator.getUserMedia = navigator.mozGetUserMedia ||
    navigator.webkitGetUserMedia || navigator.msGetUserMedia);
  toString = ->
    'audio'
  options = 
    audio: true
    video: false
    toString: toString
    
  success = (stream) ->
    src = audioContext.createMediaStreamSource stream
    analyser = audioContext.createAnalyser()
    analyser.smoothingTimeConstant = 0
    src.connect analyser
    
    canvas = $ '<canvas>'
    canvas[0].height = $(window).height() - 100
    canvas[0].width = $(window).width() - 100
    $('body').append canvas
    context = canvas[0].getContext '2d'
    noise = new Uint8Array(analyser.fftSize / 2)
    
    count = 0
    data = ->
      count++
      if count < 10
        newNoise = new Uint8Array(analyser.fftSize / 2)
        analyser.getByteFrequencyData newNoise
        for i in [0...analyser.fftSize] by 2
          noise[i / 2] = (noise[i] + newNoise[i]) / 2

      arr = new Uint8Array(analyser.fftSize)
      analyser.getByteTimeDomainData arr
      
      time = []
      for s in [0...arr.length] by 2
        time[s / 2] = arr[s]
      fft = new FFT(analyser.fftSize / 2, context.sampleRate / 2)
      fft.forward time

      context.clearRect 0 , 0 , canvas[0].width , canvas[0].height
      for i in [0...fft.spectrum.length]
        context.fillStyle = '#EEE'
        context.fillRect i*2, canvas[0].height - 10, 1.5, fft.spectrum[i] - noise[i]
      
    setInterval data, 20
    
  error = (e) ->
    console.log e
  navigator.getUserMedia options, success, error
$ ->
  if not window.AudioContext
  		if not window.webkitAudioContext
  		  throw Error 'SHITTY BROWSER'
  		window.AudioContext = window.webkitAudioContext

  $win = $(window)
  $audioFileInput = $('input')

  addEventListeners()

  $win.trigger 'resize'

  audioSrc = null
  analyser = null

  $audioFileInput.change ->
    $audioFileInput.remove()

    file = this.files[0]

    if file
      reader = new FileReader()
      reader.onload = (event) ->
        audioContext = new AudioContext()

        success = (event) ->
          audioFile = audioContext.createBufferSource()
          audioFile.buffer = event

          for c in [0...audioFile.buffer.numberOfChannels]
            channels[c] = audio: audioFile.buffer.getChannelData c
            channels[c].absolute = transform.absolute channels[c]
            channels[c].envelope = transform.envelope channels[c]
            channels[c].normalise = transform.normalise channels[c]

          create.ui()
          #create.canvas audioFile.buffer.numberOfChannels

          max = Math.max.apply Math, (channel.max for channel in channels)
          min = Math.min.apply Math, (channel.min for channel in channels)
          zoom =
            vert: 1
            hor: 1
            maxVert: max / min / 50
            maxHor: audioFile.buffer.length / 250

          #draw()

        error = (event) ->
          console.log event

        audioContext.decodeAudioData event.target.result, success, error

      reader.onerror = (event) ->
        throw Error
      reader.readAsArrayBuffer file

addEventListeners = ->
  $(window).resize ->
    canvases = $('canvas').length
    if canvases > 0
      canvasWidth = $(window).width()
      canvasHeight = Math.floor ($(window).height() / canvases) - 5
      for c in [0...canvases]
        $('canvas')[c].width = canvasWidth
        $('canvas')[c].height = canvasHeight
      update.zoom $('.slide.left'), 'VERT'
      update.zoom $('.slide.bottom'), 'HOR'
      update.scroll()
      update.threshold.zoom()
      #draw()