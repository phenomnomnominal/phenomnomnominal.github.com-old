'use strict';

// Utilities
const fs = require('fs');

// Module:
import Blog from './Blog.module';

// Dependencies:
import './Blog.controller';

const BlogDirective = {
    restrict: 'E',
    replace: true,

    /* eslint-disable no-path-concat */
    template: fs.readFileSync(`${__dirname}/blog.html`, 'utf8'),
    /* eslint-enable no-path-concat */

    controller: 'BlogController',
    controllerAs: 'blog',
    bindToController: true
};

Blog.directive('nomnomnomBlog', () => BlogDirective);
