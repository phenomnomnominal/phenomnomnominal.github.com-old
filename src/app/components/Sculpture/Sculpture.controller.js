'use strict';

// Module:
import Sculpture from './Sculpture.module';

// Dependencies:
import './Services/ThreeService';
import './Services/SceneService';

class SculptureController {
    /* @ngInject */
    constructor (
        $window,
        $http,
        SceneService,
        Three
    ) {
        this.$http = $http;
        this.scene = SceneService;
        this.three = Three;

        this.modelUrl = null;

        initResize.call(this, $window);
    }

    init () {
        let loader = new this.three.JSONLoader();

        this.$http.get(this.modelUrl)
        .then((result) => {
            let model = loader.parse(result.data, null);
            this.scene.setModel(model.geometry);
        });

        document.querySelector('.sculpture__container').appendChild(this.scene.element);
    }

    setModelUrl (value) {
        this.modelUrl = value;
    }
}

function initResize ($window) {
    $window.addEventListener('resize', resize.bind(this, $window));
    resize.call(this, $window);
}

function resize ($window) {
    var size = parseFloat($window.getComputedStyle(document.body).width);
    this.scene.setSize(size);
}

Sculpture.controller('SculptureController', SculptureController);
