'use strict';

// Utilities:
import _ from 'lodash';
import angular from 'angular';

// Module:
import Home from './Home.module';

class HomeController {
    /* @ngInject */
    constructor (
        $http,
        $window
    ) {
        var $parallaxRoot = document.querySelector('.parallax__root');
        var $parallaxContent = document.querySelector('.parallax__content');
        $window.addEventListener('resize', () => {
            collide($parallaxContent);
        });
        $parallaxRoot.addEventListener('scroll', () => {
            collide($parallaxContent);
        });
    }
}

function collide (collideTarget) {
    _.each(document.querySelectorAll('header ul li'), (element) => {
        var $element = angular.element(element);
        var elementTop = element.getBoundingClientRect().bottom;
        var collideTop = collideTarget.getBoundingClientRect().top;
        $element.toggleClass('top-header__link--hidden', collideTop < elementTop);
    });
}

Home.controller('HomeController', HomeController);
