// Generated by CoffeeScript 1.3.3
(function() {
  var Tuner, root;

  Tuner = function() {
    var analyser, audioContext, buffer, bufferFillSize, bufferFiller, downsampleRate, error, fft, fftSize, hamming, hp, i, lp, options, sampleRate, success, _i, _ref;
    navigator.getUserMedia || (navigator.getUserMedia = navigator.mozGetUserMedia || navigator.webkitGetUserMedia || navigator.msGetUserMedia);
    audioContext = new AudioContext();
    sampleRate = audioContext.sampleRate;
    downsampleRate = 8000;
    fftSize = 16384;
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
    for (i = _i = 0, _ref = fftSize / 2; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
      buffer[i] = 0;
    }
    bufferFillSize = 1024;
    bufferFiller = audioContext.createJavaScriptNode(bufferFillSize, 1, 1);
    bufferFiller.onaudioprocess = function(e) {
      var input, _j, _k, _ref1, _ref2, _results;
      for (i = _j = bufferFillSize, _ref1 = buffer.length; bufferFillSize <= _ref1 ? _j < _ref1 : _j > _ref1; i = bufferFillSize <= _ref1 ? ++_j : --_j) {
        buffer[i - bufferFillSize] = buffer[i];
      }
      input = e.inputBuffer.getChannelData(0);
      _results = [];
      for (i = _k = 0, _ref2 = input.length; 0 <= _ref2 ? _k < _ref2 : _k > _ref2; i = 0 <= _ref2 ? ++_k : --_k) {
        _results.push(buffer[buffer.length - (bufferFillSize + i)] = input[i]);
      }
      return _results;
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
        var average, f, mag2db, s, upsampled, width, zeroPad, _j, _k, _l, _m, _ref1, _ref2, _ref3, _ref4, _ref5, _results, _results1;
        hamming.process(buffer);
        zeroPad = function(a, n) {
          var _j, _results;
          _results = [];
          for (i = _j = 0; 0 <= n ? _j < n : _j > n; i = 0 <= n ? ++_j : --_j) {
            _results.push(a.push(0));
          }
          return _results;
        };
        upsampled = [];
        for (s = _j = 0, _ref1 = buffer.length; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; s = 0 <= _ref1 ? ++_j : --_j) {
          upsampled.push(buffer[s]);
          zeroPad(upsampled, 1);
        }
        fft.forward(upsampled);
        if (noiseCount < 10) {
          for (f = _k = 0, _ref2 = fft.spectrum.length; 0 <= _ref2 ? _k < _ref2 : _k > _ref2; f = 0 <= _ref2 ? ++_k : --_k) {
            if ((_ref3 = noise[f]) == null) {
              noise[f] = [];
            }
            noise[f].push(fft.spectrum[f]);
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
          for (f = _l = 0, _ref4 = fft.spectrum.length; 0 <= _ref4 ? _l < _ref4 : _l > _ref4; f = 0 <= _ref4 ? ++_l : --_l) {
            _results.push(noise[f] = average(noise[f]));
          }
          return _results;
        } else {
          context.clearRect(0, 0, canvas.width, canvas.height);
          context.fillStyle = '#EEE';
          width = (canvas.width - 100) / (fft.spectrum.length - 20);
          mag2db = function(n) {
            return 20 * (Math.log(n) / Math.log(10));
          };
          _results1 = [];
          for (i = _m = 10, _ref5 = fft.spectrum.length - 10; 10 <= _ref5 ? _m < _ref5 : _m > _ref5; i = 10 <= _ref5 ? ++_m : --_m) {
            _results1.push(context.fillRect(width * i + 1, canvas.height - 10, width, -mag2db(fft.spectrum[i] - noise[i])));
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
