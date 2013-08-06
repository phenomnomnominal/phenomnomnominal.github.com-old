# ### *[Web Audio API Chromatic Tuner](http://phenomnomnominal.github.com)*
# *tuner.coffee* contains the implementation of a pure JavaScript Chromatic Tuner, which uses the Microphone input of the computer with the **[Web Audio API](https://dvcs.w3.org/hg/audio/raw-file/tip/webaudio/specification.html)** to perform real-time pitch detection. Currently requires the latest build of Google Canary using a Mac computer with "Web Audio Input" enabled in [chrome://flags](chrome://flags).

# ___
# ## Constants:

# * **`frequencies`** - Frequencies for the `88` notes on a standard piano ([Well-tempered tuning](http://en.wikipedia.org/wiki/Well_temperament)) are stored as reference frequencies.

frequencies =
  'A0': 27.5, 'A1': 55, 'A2': 110, 'A3': 220, 'A4': 440, 'A5': 880, 'A6': 1760, 'A7': 3520.00
  'A#0': 29.1352, 'A#1': 58.2705, 'A#2': 116.541, 'A#3': 233.082, 'A#4': 466.164, 'A#5': 932.328, 'A#6': 1864.66, 'A#7': 3729.31
  'B0': 30.8677, 'B1': 61.7354, 'B2': 123.471, 'B3': 246.942, 'B4': 493.883, 'B5': 987.767, 'B6': 1975.53, 'B7': 3951.07
  'C1': 32.7032, 'C2': 65.4064, 'C3': 130.813, 'C4': 261.626, 'C5': 523.251, 'C6': 1046.50, 'C7': 2093, 'C8': 4186.01
  'C#1': 34.6478, 'C#2': 69.2957, 'C#3': 138.591, 'C#4': 277.183, 'C#5': 554.365, 'C#6': 1108.73, 'C#7': 2217.46
  'D1': 36.7081, 'D2': 73.4162, 'D3': 146.832, 'D4': 293.665, 'D5': 587.330, 'D6': 1174.66, 'D7': 2349.32
  'D#1': 38.8909, 'D#2': 77.7817, 'D#3': 155.563, 'D#4': 311.127, 'D#5': 622.254, 'D#6': 1244.51, 'D#7': 2489.02
  'E1': 41.2034, 'E2': 82.4069, 'E3': 164.814, 'E4': 329.628, 'E5': 659.255, 'E6': 1318.51, 'E7': 2637.02
  'F1': 43.6563, 'F2': 87.3071, 'F3': 174.614, 'F4': 349.228, 'F5': 698.456, 'F6': 1396.91, 'F7': 2793.83
  'F#1': 46.2493, 'F#2': 92.4986, 'F#3': 184.997, 'F#4': 369.994, 'F#5': 739.989, 'F#6': 1479.98, 'F#7': 2959.96
  'G1': 48.9994, 'G2': 97.9989, 'G3': 195.998, 'G4': 391.995, 'G5': 783.991, 'G6': 1567.98, 'G7': 3135.96
  'G#1': 51.9131, 'G#': 103.826, 'G#3': 207.652, 'G#4': 415.305, 'G#5': 830.609, 'G#6': 1661.22, 'G#7': 3322.44

# ___
# # <section id='t'>tuner:</section>

# > The main **`tuner`** function initialises the running of the tuner.
(exports ? @).tuner = do ->
  # ___
  # ## Functionality Checks:
  
  # > First there is a check for the **`AudioContext`** constructor, which is only available in Google Chrome. This is the interface to the **[Web Audio API](https://dvcs.w3.org/hg/audio/raw-file/tip/webaudio/specification.html)**, which enables the majority of the functionality required for the tuner.
  window.AudioContext = (->
    window.AudioContext or
    window.mozAudioContext or
    window.webkitAudioContext or
    window.msAudioContext or
    window.oAudioContext)()

  # > Similarly, there is a check for the **`GetUserMedia`** function, which allows the browser to have access to the audio/video input hardware of the device. Currently, there is only limited support (**Chrome** & **Opera**), but more is likely to follow.
  navigator.getUserMedia = (->
    navigator.getUserMedia or
    navigator.mozGetUserMedia or
    navigator.webkitGetUserMedia or
    navigator.msGetUserMedia or
    navigator.oGetUserMedia)()

  # ___
  # ## GetUserMedia Success:

  # > Once a successful connection is made to the user media device (microphone), the audio set-up is intialised:
  maxTime = 0
  noiseCount = 0
  noiseThreshold = -Infinity
  maxPeaks = 0
  maxPeakCount = 0
  _success = (stream) ->
    try
      # > The source of the audio (the `stream` from the microphone) is connected through the low-pass filter and the high-pass filter, and ends up in the `bufferFiller`. The `bufferFiller` must be connected to the destination, but as the `bufferFiller` does not create any output, no audible sound is played.
      src = audioContext.createMediaStreamSource stream
      src.connect lp
      lp.connect hp
      hp.connect bufferFiller
      bufferFiller.connect audioContext.destination
      
      # > ### Process:
      # > ___
      
      # > 10 times a second, the data in the buffer is proccessed. This involves several steps:
      process = ->
        # > 1. A copy is made of the buffer data
        #
        # > 2. The Gaussian window is applied to the buffer data.
        #
        # > 3. The buffer data is downsampled by a factor of four.
        #
        # > 4. The downsampled data is restored to the original data rate by inserting `0`s.
        #
        # > 5. The FFT is then applied to the upsampled data.
        #
        # > 6. The first `10` times that the data is examined (i.e. the first second), the frequency spectrum is examined with the assumption that any data recieved is pure noise. The maximum value from the spectrums and these `10` intervals is set to be the `noiseThreshold`. The `noiseThreshold` is limited to being `0.001`, just in case there was valid data in the samples.
        #
        # > 7. The values from the FFT spectrum are sorted by their peak value.
        #
        # > 8. The top `8` highest peaks are selected, provided they are sufficiently large.
        #
        # > 9. If there are any peaks found, any values from either side of the peaks are removed (as they are also likely to be peaks, but they provide no useful information). The remaining peaks are sorted by their frequency again, with lower values having lover indexes.
        #
        # > 10. The maximum number of peaks that has been seen recently is recorded, as it is sometimes the case that harmonics are percieved longer that the fundamental.
        #
        # > 11. We can check if the highest peak is a harmonic by checking the most common frequency rations - namely `1.5` times the fundamental (perfect 5th) and `2` times the fundamental (perfect octave) - and then swap the values if needed.
        #
        # > 12. If we have found a maximal peak in the FFT Spectrum, parabolic interpolation is performed on the log of the peak and the values either side, giving an accurate frequency representation.
        #
        # > 13. The frequency estimation is used to determing the pitch being played by looking it up in the known frequency table.
        #
        # > 14. The closest pitch, and whether the current tone is sharp or flat is displayed to the user.
        #
        # > 15. If no large enough peaks are found, the display isn't changed, and if none are found for a sufficiently long time, the display is cleared.
        
        bufferCopy = (b for b in buffer)
        
        gauss.process bufferCopy
    
        downsampled = []
        for s in [0...bufferCopy.length] by 4
          downsampled.push bufferCopy[s]
    
        upsampled = []
        for s in downsampled
          upsampled.push s
          upsampled.push 0
          upsampled.push 0
          upsampled.push 0
    
        fft.forward upsampled
    
        if noiseCount < 10
          noiseThreshold = _.reduce(fft.spectrum, 
            ((max, next) -> 
              if next > max then next else max)
            , noiseThreshold)
          noiseThreshold = if noiseThreshold > 0.001 then 0.001 else noiseThreshold
          noiseCount++
      
        spectrumPoints = (x: x, y: fft.spectrum[x] for x in [0...(fft.spectrum.length / 4)])
        spectrumPoints.sort (a, b) -> (b.y - a.y)
    
        peaks = []
        for p in [0...8]
          if spectrumPoints[p].y > noiseThreshold * 5
            peaks.push spectrumPoints[p]
        
        if peaks.length > 0
          for p in [0...peaks.length]
            if peaks[p]?
              for q in [0...peaks.length]
                if p isnt q and peaks[q]?
                  if Math.abs(peaks[p].x - peaks[q].x) < 5
                    peaks[q] = null
          peaks = (p for p in peaks when p?)
          peaks.sort (a, b) -> (a.x - b.x)
          
          maxPeaks = if maxPeaks < peaks.length then peaks.length else maxPeaks
          if maxPeaks > 0 then maxPeakCount = 0
          
          peak = null
          
          firstFreq = peaks[0].x * (sampleRate / fftSize)
          if peaks.length > 1
            secondFreq = peaks[1].x * (sampleRate / fftSize)
            if 1.4 < (firstFreq / secondFreq) < 1.6
              peak = peaks[1]
          if peaks.length > 2
            thirdFreq = peaks[2].x * (sampleRate / fftSize)
            if 1.4 < (firstFreq / thirdFreq) < 1.6
              peak = peaks[2]

          if peaks.length > 1 or maxPeaks is 1
            if not peak?
              peak = peaks[0]
        
            left = x: peak.x - 1, y: Math.log(fft.spectrum[peak.x - 1])
            peak = x: peak.x, y: Math.log(fft.spectrum[peak.x])
            right = x: peak.x + 1, y: Math.log(fft.spectrum[peak.x + 1])
        
            interp = (0.5 * ((left.y - right.y) / (left.y - (2 * peak.y) + right.y)) + peak.x)
            freq = interp * (sampleRate / fftSize)
            
            [note, diff] = getPitch freq
            
            display.draw note, diff
        else
          maxPeaks = 0
          maxPeakCount++
          if maxPeakCount > 20
            display.clear()

      # > ### Start process loop:
      # > ___

      # > Once all the functions are initialised, an interval loop is set up with calls the **`process`** function `10` times per second.
      interval = setInterval process, 100

    catch e
      _alertError e
      
    # > ### getPitch:
    # > ___
      
    # > The **`getPitch`** function takes the current estimated frequency and finds the closest pitch to that frequency. It also returns the distance from the current frequency to the in-tune pitch of the note.
    getPitch = (freq) ->
      minDiff = Infinity
      diff = Infinity
      for own key, val of frequencies
        if Math.abs(freq - val) < minDiff
          minDiff = Math.abs(freq - val)
          diff = freq - val
          note = key
      [note, diff]
  
    # > ### display:
    # > ___
    
    # > The display functions (**`draw`** and **`clear`**) simply update the display to show which pitch is closest and whether the current pitch is sharper or flatter, and clear the display.
    display = 
      draw: (note, diff) ->
        displayDiv = $('.tuner div')
        displayDiv.removeClass()
        displayDiv.addClass (if Math.abs(diff) < 0.25 then 'inTune' else 'outTune')
        note = note.replace(/[0-9]*/g, '')
        if Math.abs(diff) < 0.25
          if note.length is 2
            displayStr = "<&nbsp;&nbsp;#{note}&nbsp;>"
          else
            displayStr = "<&nbsp;&nbsp;#{note}&nbsp;&nbsp;>"
        else
          if note.length is 2
            displayStr = ''
            displayStr += if diff > 0.25 then '<&nbsp;&nbsp;' else '&nbsp;&nbsp;&nbsp;'
            displayStr += note
            displayStr += if diff < -0.25 then '&nbsp;>' else '&nbsp;&nbsp;'
          else
            displayStr = ''
            displayStr += if diff > 0.25 then '<&nbsp;&nbsp;' else '&nbsp;&nbsp;&nbsp;'
            displayStr += note
            displayStr += if diff < -0.25 then '&nbsp;&nbsp;>' else '&nbsp;&nbsp;&nbsp;'
        displayDiv.html displayStr
        
      clear: ->
        displayDiv = $('.tuner div')
        displayDiv.removeClass()
        displayDiv.html ''

  # ___
  # ## GetUserMedia Error:
  
  # > An error function is also required for when something goes wrong with accessing the user microphone.
  _alertError = (e) ->
    debugger
    alert 'ERROR: CHECK ERROR CONSOLE'
    console.error e

  # ___
  # ## Initialisation:
  
  # > When the tuner is initialised, the canvas element is created and a resize listener is added so that it correctly fits the display window. This event is manually triggered to initialise the size of the canvas.
  interval = canvas = context = audioContext = sampleRate = fftSize = lp = hp = gauss = fft = buffer = bufferFiller = null
  init = ($container) ->
    $CONTAINER = $container
    $CONTAINER.empty()
    canvas = $('<canvas>').get 0
    $CONTAINER.append canvas
  
    $(window).resize ->
      canvas.height = $CONTAINER.height()
      canvas.width = $CONTAINER.width()
    $(window).trigger 'resize'

  # ___
  # ## Context Initialisation:

  # > In order to actually do anything, the 2D drawing context for the canvas and the audio manipulation context need to be accessed.
    context = canvas.getContext '2d'
    audioContext = new AudioContext()

  # ___
  # ## DSP Initialisation:
  
  # > ### Fast Fourier Transform:
  # > ___

  # >> The incoming audio from the microphone has a sample rate (F<sub>s</sub>) of `44100Hz`. Since the highest possible frequency we are interested in is the 'Top C' on the piano (`4186.01Hz`), we can safely ignore data over roughly `10KHz`. The downsampled rate that we use is `11025Hz` (F<sub>s</sub> / 4). 
  #
  # >> As the FFT requires a input of length 2<sup>n</sup>, we use `8192` (2<sup>13</sup>).
  #
  # >> The relationship between FFT sample rate, FFT buffer length and FFT bin resolution, is:
  #
  # >>> **FFT<sub>r</sub> = FFT<sub>s</sub> / FFT<sub>L</sub>**
  #
  # >> FFT<sub>s</sub> of `11025Hz` and FFT buffer length of `8192` gives us a bin resolution of `1.3458Hz`
    sampleRate = audioContext.sampleRate
    fftSize = 8192
    fft = new FFT(fftSize, sampleRate / 4)
  
  # > ### Sample Buffer:
  # > ___

  # >> In order to always have enough data to get sufficient resolution while maintaining the real-time requirement of a tuner, a shifting window buffer is used. This buffer always contains `8192` samples, however the buffer windows shifts every `2048` samples.
    buffer = (0 for i in [0...fftSize])
    bufferFillSize = 2048
    bufferFiller = audioContext.createJavaScriptNode bufferFillSize, 1, 1
    bufferFiller.onaudioprocess = (e) ->
      input = e.inputBuffer.getChannelData 0
      for b in [bufferFillSize...buffer.length]
        buffer[b - bufferFillSize] = buffer[b]
      for b in [0...input.length]
        buffer[buffer.length - bufferFillSize + b] = input[b]
  
  # > ### Filters:
  # > ___
  
  # >> Three filters are used:
  #
  # >> * **`gauss`** - A **[Gaussian](http://en.wikipedia.org/wiki/Window_function#Gaussian_windows)** window function is used on the time-domain buffer data. A Gaussian function is also Gaussian in the frequency-domain. Since the *log* of a Gaussian is a parabola, the resulting data can be used for exact parabolic interpolation in the frequency domain, allowing for highly accurate frequency estimation.
  #
  # >> * **`lp`** - A **[low-pass filter](http://en.wikipedia.org/wiki/Low-pass_filter)** is also used to attenuate frequencies above `8KHz`, as we are not interested in these frequencies.
  #
  # >> * **`hp`** - A **[high-pass filter](http://en.wikipedia.org/wiki/High-pass_filter)** is used to attenuate frequencies below `20Hz`, as we are not interested in these frequencies (and they are outside the frequency response of many basic microphones anyway).
    gauss = new WindowFunction(DSP.GAUSS)

    lp = audioContext.createBiquadFilter()
    lp.type = lp.LOWPASS
    lp.frequency = 8000
    lp.Q = 0.1

    hp = audioContext.createBiquadFilter()
    hp.type = hp.HIGHPASS
    hp.frequency = 20
    hp.Q = 0.1

  # ___
  # ## Access user media:

  # > Once everything needed for the tuner is initialised, we attempt to access an audio stream from the microphone.
    navigator.getUserMedia audio: true, _success, _alertError

  # > ### update:
  # > ___

  # > The **`update`** function uses the HTML5 Canvas element to draw both the time-domain and frequency-domain data to display it to the user.
  update = ->
    debugger
    context.clearRect 0, 0, canvas.width, canvas.height
    newMaxTime = _.reduce buffer, ((max, next) -> if Math.abs(next) > max then Math.abs(next) else max), -Infinity
    maxTime = if newMaxTime > maxTime then newMaxTime else maxTime
    timeWidth = (canvas.width) / (buffer.length)
    context.fillStyle = '#494'
    for s in [0...buffer.length]
      context.fillRect timeWidth * s, 250, timeWidth, -(canvas.height / 4) * (buffer[s] / maxTime)
    freqWidth = (canvas.width) / (fft.spectrum.length / 8)
    context.fillStyle = '#449'
    for f in [0...(fft.spectrum.length / 8)]
      context.fillRect freqWidth * f, canvas.height - 50, freqWidth, -Math.pow(5e3 * fft.spectrum[f], 1.75)

  kill = ->
    bufferFiller.onaudioprocess = null
    clearInterval interval

  init: init
  update: update
  kill: kill