'use strict';

// Utilities:
var gulp = require('gulp');

// Dependencies:
var eslint = require('gulp-eslint');

module.exports = {
    client: client
};

function client () {
    return gulp.src(['src/app/**/*.js'])
    .pipe(eslint())
    .pipe(eslint.format());
}
