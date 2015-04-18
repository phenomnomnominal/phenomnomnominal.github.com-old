'use strict';

// Utilities:
var gulp = require('gulp');
var karma = require('karma').server;

module.exports = {
    client: client
};

function client (reportTaskDone) {
    karma.start({
        frameworks: ['browserify', 'mocha', 'sinon-chai'],
        browsers: ['Chrome'],

        port: 9876,

        reporters: ['progress', 'coverage'],
        coverageReporter: {
            reporters: [{
                type: 'lcov',
                dir: 'reports/client'
            }, {
                type: 'text',
                dir: 'reports/client'
            }]
        },

        colors: true,
        autoWatch: false,
        singleRun: true,

        files: [
            'src/**/*.spec.js'
        ],

        preprocessors: {
            'src/**/*.spec.js': ['browserify']
        },

        browserify: {
            transform: ['brfs', 'browserify-shim', ['browserify-istanbul', {
                ignore: ['**/*.spec.js', '**/*.mock.js', '**/Errors/*.js']
            }]]
        }
    }, function () {
        reportTaskDone();
    });
}
