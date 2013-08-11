(function () {
  Modernizr.webgl = Modernizr.webgl && (function() {
    var canvas;
    canvas = document.createElement('canvas');
    return (canvas.getContext('webgl') != null) || (canvas.getContext('experimental-webgl') != null);
  })();
})()