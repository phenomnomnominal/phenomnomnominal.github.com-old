do ->
  BASE = 'libraries/polyfills/'

  yepnope
    test: Modernizr.fullscreen
    yep: "#{BASE}fullscreen.js"
    nope: "#{BASE}fullscreen.js"

  yepnope
    test: Modernizr.mediaqueries
    nope: "#{BASE}matchMedia.js"

  yepnope
    test: Modernizr.raf
    nope: '#{BASE}rAF.js'

  yepnope
    test: Modernizr.classlist
    nope: "#{BASE}classList.js"