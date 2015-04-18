'use strict';

// Utilities:
import angular from 'angular';

// Module:
import Blog from './Blog.module';

// Dependencies:
import Prism from 'prismjs';
import 'prismjs-line-numbers';

class BlogController {
    /* @ngInject */
    constructor (
        $http,
        $location,
        $rootScope,
        $state,
        $stateParams,
        $scope,
        $window
    ) {
        this.$location = $location;
        this.$scope = $scope;
        this.$window = $window;

        this.title = $stateParams.id;
        $http.get(`/web/content/${this.title}.md`)
        .then(result => {
            this.post = result.data;
            this.postLoaded();
        })
        .catch(() => {
            $state.go('phenomnomnominal.posts');
        });
    }

    postLoaded() {
        this.initHighlight();
        this.initComments();
    }

    initHighlight () {
        this.$scope.$watch('blog.post', () => {
            this.$scope.$evalAsync(() => {
                let code = document.querySelectorAll('pre');
                if (code.length) {
                    angular.element(code)
                    .addClass('language-javascript')
                    .addClass('line-numbers');

                    Prism.highlightAll();
                }
            });
        });
    }

    initComments () {
        if (this.$window.DISQUS) {
            this.$window.DISQUS.reset({
                reload: true,
                config: () => {
                    this.page.identifier = this.title;
                    this.page.url = this.$location.absUrl();
                }
            });
        } else {
            var disqus_shortname = 'phenomnomnominal';
            var dsq = document.createElement('script');
            dsq.type = 'text/javascript';
            dsq.async = true;
            dsq.src = '//' + disqus_shortname + '.disqus.com/embed.js';
            (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);
        }
    }
}

Blog.controller('BlogController', BlogController);
