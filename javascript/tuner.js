// Generated by CoffeeScript 1.3.3
(function() {
  var Tuner, root;

  Tuner = function() {
    var analyser, audioContext, buffer, bufferFillSize, bufferFiller, downsampleRate, error, fft, fftSize, gauss, hp, i, lp, options, sampleRate, success, _i;
    navigator.getUserMedia || (navigator.getUserMedia = navigator.mozGetUserMedia || navigator.webkitGetUserMedia || navigator.msGetUserMedia);
    audioContext = new AudioContext();
    sampleRate = audioContext.sampleRate;
    downsampleRate = sampleRate / 4;
    fftSize = 8192;
    fft = new FFT(fftSize, downsampleRate);
    gauss = new WindowFunction(DSP.GAUSS);
    lp = audioContext.createBiquadFilter();
    lp.type = lp.LOWPASS;
    lp.frequency = 20;
    lp.Q = 0.1;
    hp = audioContext.createBiquadFilter();
    hp.type = hp.HIGHPASS;
    hp.frequency = 4000;
    hp.Q = 0.1;
    buffer = [];
    for (i = _i = 0; 0 <= fftSize ? _i < fftSize : _i > fftSize; i = 0 <= fftSize ? ++_i : --_i) {
      buffer[i] = 0;
    }
    bufferFillSize = 2048;
    bufferFiller = audioContext.createJavaScriptNode(bufferFillSize, 1, 1);
    bufferFiller.onaudioprocess = function(e) {
      var b, input, _j, _k, _ref, _ref1, _results;
      for (b = _j = bufferFillSize, _ref = buffer.length; bufferFillSize <= _ref ? _j < _ref : _j > _ref; b = bufferFillSize <= _ref ? ++_j : --_j) {
        buffer[b - bufferFillSize] = buffer[b];
      }
      input = e.inputBuffer.getChannelData(0);
      _results = [];
      for (b = _k = 0, _ref1 = input.length; 0 <= _ref1 ? _k < _ref1 : _k > _ref1; b = 0 <= _ref1 ? ++_k : --_k) {
        _results.push(buffer[buffer.length - bufferFillSize + b] = input[b]);
      }
      return _results;
    };
    analyser = audioContext.createAnalyser();
    options = {
      audio: true,
      video: false
    };
    success = function(stream) {
      var canvas, context, data, maxFreq, maxTime, noiseCount, noiseThreshold, parabolicInterp, src;
      src = audioContext.createMediaStreamSource(stream);
      src.connect(lp);
      lp.connect(hp);
      hp.connect(bufferFiller);
      bufferFiller.connect(analyser);
      $('.tuner').removeClass('hidden');
      canvas = $('#tuner_canvas')[0];
      canvas.height = $('.tuner').height();
      canvas.width = $('.tuner').width();
      context = canvas.getContext('2d');
      maxTime = 0;
      maxFreq = 0;
      noiseCount = 0;
      noiseThreshold = -Infinity;
      parabolicInterp = function(left, peak, right) {
        return (0.5 * ((left.y - right.y) / (left.y - (2 * peak.y) + right.y)) + peak.x) * (sampleRate / fftSize);
      };
      data = function() {
        var b, bufferCopy, downsampled, f, firstFreq, freq, freqWidth, left, newMaxTime, p, peak, peaks, q, right, s, secondFreq, spectrumPoints, timeWidth, upsampled, x, _j, _k, _l, _len, _m, _n, _o, _p, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6, _results;
        bufferCopy = (function() {
          var _j, _len, _results;
          _results = [];
          for (_j = 0, _len = buffer.length; _j < _len; _j++) {
            b = buffer[_j];
            _results.push(b);
          }
          return _results;
        })();
        gauss.process(bufferCopy);
        downsampled = [];
        for (s = _j = 0, _ref = bufferCopy.length; _j < _ref; s = _j += 4) {
          downsampled.push(bufferCopy[s]);
        }
        upsampled = [];
        for (_k = 0, _len = downsampled.length; _k < _len; _k++) {
          s = downsampled[_k];
          upsampled.push(s);
          upsampled.push(0);
          upsampled.push(0);
          upsampled.push(0);
        }
        fft.forward(upsampled);
        context.clearRect(0, 0, canvas.width, canvas.height);
        newMaxTime = _.reduce(buffer, (function(max, next) {
          if (Math.abs(next) > max) {
            return Math.abs(next);
          } else {
            return max;
          }
        }), -Infinity);
        maxTime = newMaxTime > maxTime ? newMaxTime : maxTime;
        context.fillStyle = '#EEE';
        timeWidth = (canvas.width - 100) / upsampled.length;
        for (s = _l = 0, _ref1 = upsampled.length; 0 <= _ref1 ? _l < _ref1 : _l > _ref1; s = 0 <= _ref1 ? ++_l : --_l) {
          context.fillRect(timeWidth * s, canvas.height / 2, timeWidth, -(canvas.height / 2) * (buffer[s] / maxTime));
        }
        if (noiseCount < 10) {
          noiseThreshold = _.reduce(fft.spectrum, (function(max, next) {
            if (next > max) {
              return next;
            } else {
              return max;
            }
          }), noiseThreshold);
          noiseCount++;
        }
        spectrumPoints = (function() {
          var _m, _ref2, _results;
          _results = [];
          for (x = _m = 0, _ref2 = fft.spectrum.length / 4; 0 <= _ref2 ? _m < _ref2 : _m > _ref2; x = 0 <= _ref2 ? ++_m : --_m) {
            _results.push({
              x: x,
              y: fft.spectrum[x]
            });
          }
          return _results;
        })();
        spectrumPoints.sort(function(a, b) {
          if (a.y > b.y) {
            return -1;
          } else if (a.y === b.y) {
            return 0;
          }
          if (a.y < b.y) {
            return 1;
          }
        });
        peaks = [];
        for (p = _m = 0; _m < 8; p = ++_m) {
          if (spectrumPoints[p].y > noiseThreshold * 2) {
            peaks.push(spectrumPoints[p]);
          }
        }
        if (peaks.length > 0) {
          for (p = _n = 0, _ref2 = peaks.length; 0 <= _ref2 ? _n < _ref2 : _n > _ref2; p = 0 <= _ref2 ? ++_n : --_n) {
            if (peaks[p] != null) {
              for (q = _o = 0, _ref3 = peaks.length; 0 <= _ref3 ? _o < _ref3 : _o > _ref3; q = 0 <= _ref3 ? ++_o : --_o) {
                if (p !== q && (peaks[q] != null)) {
                  if (Math.abs(peaks[p].x - peaks[q].x) < 5) {
                    peaks[q] = null;
                  }
                }
              }
            }
          }
          peaks = (function() {
            var _len1, _p, _results;
            _results = [];
            for (_p = 0, _len1 = peaks.length; _p < _len1; _p++) {
              p = peaks[_p];
              if (p != null) {
                _results.push(p);
              }
            }
            return _results;
          })();
          firstFreq = peaks[0].x * (sampleRate / fftSize);
          secondFreq = peaks[1].x * (sampleRate / fftSize);
          peak = null;
          if ((1.4 < (_ref4 = firstFreq / secondFreq) && _ref4 < 1.6)) {
            peak = peaks[1];
          } else if ((1.9 < (_ref5 = firstFreq / secondFreq) && _ref5 < 2.1)) {
            peak = peaks[1];
          } else {
            peak = peaks[0];
          }
          left = {
            x: peak.x - 1,
            y: fft.spectrum[peak.x - 1]
          };
          right = {
            x: peak.x + 1,
            y: fft.spectrum[peak.x + 1]
          };
          freq = parabolicInterp(left, peak, right);
          if ((320 < freq && freq < 340)) {
            debugger;
          }
          console.log('F: ', freq);
        }
        context.fillStyle = '#F77';
        freqWidth = (canvas.width - 100) / (fft.spectrum.length / 4);
        _results = [];
        for (f = _p = 10, _ref6 = (fft.spectrum.length / 4) - 10; 10 <= _ref6 ? _p < _ref6 : _p > _ref6; f = 10 <= _ref6 ? ++_p : --_p) {
          _results.push(context.fillRect(freqWidth * f, canvas.height / 2, freqWidth, -Math.pow(5 * fft.spectrum[f], 2)));
        }
        return _results;
      };
      return setInterval(data, 100);
    };
    error = function(e) {
      return console.log(e);
    };
    return navigator.getUserMedia(options, success, error);
  };

  $(function() {
    if (!window.AudioContext) {
      if (!window.webkitAudioContext) {
        throw Error('SHITTY BROWSER');
      }
      return window.AudioContext = window.webkitAudioContext;
    }
  });

  root = typeof exports !== "undefined" && exports !== null ? exports : this;

  root.Tuner = Tuner;

}).call(this);
