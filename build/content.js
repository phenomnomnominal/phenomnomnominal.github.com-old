'use strict';

// Config:
var config = require('./config.js');

// Utilities:
var gulp = require('gulp');

// Dependencies:
var browserSync = require('browser-sync');

module.exports = content;

function content () {
    return gulp.src(config.src + '/content/*')
    .pipe(gulp.dest(config.dest + '/content/'))
    .pipe(browserSync.reload({
        stream: true
    }));
}
