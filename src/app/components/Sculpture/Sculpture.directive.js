'use strict';

// Utilities
import _ from 'lodash';
const fs = require('fs');

// Module:
import Sculpture from './Sculpture.module';

// Dependencies:
import './Sculpture.controller';

const SculptureDirective = {
    restrict: 'E',
    replace: true,

    /* eslint-disable no-path-concat */
    template: fs.readFileSync(`${__dirname}/sculpture.html`, 'utf8'),
    /* eslint-enable no-path-concat */

    controller: 'SculptureController',
    controllerAs: 'sculpture',
    bindToController: true,
    link: link
};

function link ($scope, $element, $attrs) {
    if (_.isUndefined($attrs.modelFilePath)) {
        throw new Error('The "nomnomnom-sculpture" directive requires a "modelFilePath" attribute.');
    }

    $scope.sculpture.setModelUrl($attrs.modelFilePath);
    $scope.sculpture.init();
}

Sculpture.directive('nomnomnomSculpture', () => SculptureDirective);
