'use strict';

// Utilities:
const fs = require('fs');
import Promise from 'bluebird';

// Dependencies:
import angular from 'angular';
import marked from 'marked';
import 'angular-ui-router';
import 'angular-marked';

import './Core.module';
import './components/Home/Home.module';
import './components/Home/Home.controller';
import './components/Posts/Posts.module';
import './components/Posts/Posts.controller';
import './components/Blog/Blog.module';
import './components/Blog/Blog.directive';
import './components/Sculpture/Sculpture.module';
import './components/Sculpture/Sculpture.directive';

const phenomnomnominal = angular.module('phenomnomnominal', [
    'ui.router',
    'hc.marked',
    'Core',
    'Home',
    'Posts',
    'Blog',
    'Sculpture'
]);

phenomnomnominal.config(($stateProvider, $urlRouterProvider, $locationProvider) => {
    'ngInject';

    $urlRouterProvider.otherwise('/posts');

    $stateProvider
    .state('phenomnomnominal', {
        abstract: true,
        url: '/posts',
        /* eslint-disable no-path-concat */
        template: fs.readFileSync(`${__dirname}/components/Home/home.html`, 'utf8'),
        /* eslint-enable no-path-concat */
        controller: 'HomeController as home'
    })
    .state('phenomnomnominal.posts', {
        url: '',
        /* eslint-disable no-path-concat */
        template: fs.readFileSync(`${__dirname}/components/Posts/posts.html`, 'utf8'),
        /* eslint-enable no-path-concat */
        controller: 'PostsController as posts'
    })
    .state('phenomnomnominal.post', {
        url: '/:id',
        /* eslint-disable no-path-concat */
        template: fs.readFileSync(`${__dirname}/components/Post/post.html`, 'utf8')
        /* eslint-enable no-path-concat */
    });
});

phenomnomnominal.run(($rootScope, $window, $state) => {
    'ngInject';

    Promise.longStackTraces();
    Promise.setScheduler(cb => {
        $rootScope.$evalAsync(cb);
    });
    $window.marked = marked;
});
