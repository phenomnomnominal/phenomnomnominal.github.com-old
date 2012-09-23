// Generated by CoffeeScript 1.3.3
(function() {
  var Tuner, root;

  Tuner = function() {
    var analyser, audioContext, buffer, bufferFillSize, bufferFiller, downsampleRate, error, fft, fftSize, hamming, hp, i, lp, options, sampleRate, success, _i;
    navigator.getUserMedia || (navigator.getUserMedia = navigator.mozGetUserMedia || navigator.webkitGetUserMedia || navigator.msGetUserMedia);
    audioContext = new AudioContext();
    sampleRate = audioContext.sampleRate;
    downsampleRate = sampleRate / 4;
    fftSize = 8192;
    fft = new FFT(fftSize, downsampleRate);
    hamming = new WindowFunction(DSP.HAMMING);
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
    bufferFillSize = 1024;
    bufferFiller = audioContext.createJavaScriptNode(bufferFillSize, 1, 1);
    bufferFiller.onaudioprocess = function(e) {
      var input, output, _j, _k, _ref, _ref1;
      for (i = _j = bufferFillSize, _ref = buffer.length; bufferFillSize <= _ref ? _j < _ref : _j > _ref; i = bufferFillSize <= _ref ? ++_j : --_j) {
        buffer[i - bufferFillSize] = buffer[i];
      }
      input = e.inputBuffer.getChannelData(0);
      for (i = _k = 0, _ref1 = input.length; 0 <= _ref1 ? _k < _ref1 : _k > _ref1; i = 0 <= _ref1 ? ++_k : --_k) {
        buffer[buffer.length - bufferFillSize + i] = input[i];
      }
      return output = e.outputBuffer.getChannelData(0);
    };
    analyser = audioContext.createAnalyser();
    options = {
      audio: true,
      video: false
    };
    success = function(stream) {
      var canvas, context, data, fillBuffer, noise, noiseCount, src;
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
      noise = [];
      noiseCount = 0;
      fillBuffer = function() {};
      data = function() {
        var average, denoised, downsampled, f, freqWidth, mag2db, max, s, timeWidth, upsampled, _j, _k, _l, _len, _m, _n, _o, _p, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6, _results, _results1;
        downsampled = [];
        for (s = _j = 0, _ref = buffer.length; _j < _ref; s = _j += 4) {
          downsampled.push(buffer[s]);
        }
        upsampled = [];
        for (_k = 0, _len = downsampled.length; _k < _len; _k++) {
          s = downsampled[_k];
          upsampled.push(s);
          upsampled.push(0);
          upsampled.push(0);
          upsampled.push(0);
        }
        if (noiseCount < 10) {
          for (f = _l = 0, _ref1 = upsampled.length; 0 <= _ref1 ? _l < _ref1 : _l > _ref1; f = 0 <= _ref1 ? ++_l : --_l) {
            if ((_ref2 = noise[f]) == null) {
              noise[f] = [];
            }
            noise[f].push(upsampled[f]);
          }
          return noiseCount++;
        } else if (noiseCount === 10) {
          noiseCount++;
          average = function(arr) {
            return (_.reduce(arr, (function(sum, next) {
              return sum + next;
            }), 0)) / arr.length;
          };
          _results = [];
          for (f = _m = 0, _ref3 = upsampled.length; 0 <= _ref3 ? _m < _ref3 : _m > _ref3; f = 0 <= _ref3 ? ++_m : --_m) {
            _results.push(noise[f] = average(noise[f]));
          }
          return _results;
        } else {
          denoised = [];
          for (s = _n = 0, _ref4 = upsampled.length; 0 <= _ref4 ? _n < _ref4 : _n > _ref4; s = 0 <= _ref4 ? ++_n : --_n) {
            denoised.push(upsampled[s] - noise[s]);
          }
          fft.forward(denoised);
          context.clearRect(0, 0, canvas.width, canvas.height);
          mag2db = function(n) {
            return 20 * (Math.log(n) / Math.log(10));
          };
          max = _.reduce(denoised, (function(max, next) {
            if (Math.abs(next) > max) {
              return Math.abs(next);
            } else {
              return max;
            }
          }), 0);
          timeWidth = (canvas.width - 100) / fft.spectrum.length;
          context.fillStyle = '#EEE';
          for (i = _o = 0, _ref5 = fft.spectrum.length; 0 <= _ref5 ? _o < _ref5 : _o > _ref5; i = 0 <= _ref5 ? ++_o : --_o) {
            context.fillRect(timeWidth * i, canvas.height / 2, timeWidth, -(canvas.height / 2) * (denoised[i] / max));
          }
          freqWidth = (canvas.width - 100) / (fft.spectrum.length / 2);
          context.fillStyle = '#F77';
          _results1 = [];
          for (i = _p = 10, _ref6 = fft.spectrum.length / 2; 10 <= _ref6 ? _p < _ref6 : _p > _ref6; i = 10 <= _ref6 ? ++_p : --_p) {
            _results1.push(context.fillRect(freqWidth * i, canvas.height / 2, freqWidth, -Math.abs(mag2db(fft.spectrum[i] - noise[i]))));
          }
          return _results1;
        }
      };
      return setInterval(data, 25);
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
