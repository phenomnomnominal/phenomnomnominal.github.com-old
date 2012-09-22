// Generated by CoffeeScript 1.3.3
(function() {
  var Tuner, root;

  Tuner = function() {
    var audioContext, buffer, error, fft, hamming, hp, lp, options, success;
    navigator.getUserMedia || (navigator.getUserMedia = navigator.mozGetUserMedia || navigator.webkitGetUserMedia || navigator.msGetUserMedia);
    audioContext = new AudioContext();
    hamming = new WindowFunction(DSP.HAMMING);
    hp = new IIRFilter2(DSP.HIGHPASS, 20, 0.1, 44100 / 8);
    lp = new IIRFilter2(DSP.LOWPASS, 8000, 0.1, 44100 / 8);
    fft = new FFT(8192, audioContext.sampleRate / 8);
    buffer = [];
    options = {
      audio: true,
      video: false
    };
    success = function(stream) {
      var analyser, canvas, context, data, src;
      src = audioContext.createMediaStreamSource(stream);
      analyser = audioContext.createAnalyser();
      src.connect(analyser);
      $('.tuner').removeClass('hidden');
      canvas = $('#tuner_canvas')[0];
      canvas.height = $('.tuner').height();
      canvas.width = $('.tuner').width();
      context = canvas.getContext('2d');
      data = function() {
        var downSampled, i, s, time, width, zeroPad, _i, _j, _ref, _ref1, _results;
        time = new Uint8Array(analyser.fftSize);
        analyser.getByteTimeDomainData(time);
        hamming.process(time);
        lp.process(time);
        hp.process(time);
        zeroPad = function(a, n) {
          var i, _i, _results;
          _results = [];
          for (i = _i = 0; 0 <= n ? _i < n : _i > n; i = 0 <= n ? ++_i : --_i) {
            _results.push(a.push(0));
          }
          return _results;
        };
        downSampled = [];
        for (s = _i = 0, _ref = time.length; _i < _ref; s = _i += 8) {
          downSampled.push(time[s]);
          zeroPad(downSampled, 11);
        }
        fft.forward(downSampled);
        context.clearRect(0, 0, canvas.width, canvas.height);
        context.fillStyle = '#EEE';
        width = (canvas.width - 100) / (fft.spectrum.length - 20);
        _results = [];
        for (i = _j = 10, _ref1 = fft.spectrum.length - 10; 10 <= _ref1 ? _j < _ref1 : _j > _ref1; i = 10 <= _ref1 ? ++_j : --_j) {
          _results.push(context.fillRect(width * i + 1, canvas.height - 10, width, -100 * Math.log(fft.spectrum[i])));
        }
        return _results;
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
