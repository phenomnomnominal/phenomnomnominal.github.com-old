'use strict';

// Utilities:
import _ from 'lodash';
import { param } from 'change-case';

// Module:
import Posts from './Posts.module';

// Dependencies
import './Date.filter';

class PostsController {
    /* @ngInject */
    constructor (
        $http
    ) {
        $http.get('/web/content/posts.json')
        .then((result) => {
            this.posts = _.map(result.data, (post) => {
                post.url = param(post.name);
                return post;
            });
        });
    }
}

Posts.controller('PostsController', PostsController);
