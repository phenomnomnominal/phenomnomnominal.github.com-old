'use strict';

// Utilities:
import _ from 'lodash';

// Module:
import Sculpture from '../Sculpture.module';

var SceneService = function SceneService (
    Three
) {
    'ngInject';

    let scene = initScene();
    let renderer = initRenderer();
    let camera = initCamera(scene);

    const SCULPTURE = 'sculpture';

    const SCALE = 1.001;
    const ROTATE = 0.01;
    const FFFFFF = 0xFFFFFF;

    let grow = true;

    render();

    return {
        element: renderer.domElement,
        setModel,
        setSize,
        render
    };

    function setModel (geometry) {
        let model = new Three.Mesh(geometry, new Three.MeshBasicMaterial({
            wireframe: true,
            wireframeLinewidth: 2.5
        }));
        model.scale.multiplyScalar(175);
        model.position.y -= 25;
        model.name = SCULPTURE;
        scene.children = _.filter(scene.children, (child) => {
            return child.name !== SCULPTURE;
        });
        scene.add(model);
    }

    function setSize (size) {
        renderer.setSize(size, size);
    }

    function initScene () {
        return new Three.Scene();
    }

    function initRenderer () {
        let options = {
            devicePixelRatio: window.devicePixelRatio || 1
        };
        return supportsWebGL() ? new Three.WebGLRenderer(options) : new Three.CanvasRenderer(options);
    }

    function supportsWebGL() {
        try {
            return !!window.WebGLRenderingContext &&
                !!document.createElement('canvas').getContext('experimental-webgl');
        } catch (e) {
            return false;
        }
    }

    function initCamera (scene) {
        let camera = new Three.PerspectiveCamera(45, 1, 0.1, 10000);
        camera.position.set(400, 0, 0);
        camera.lookAt(new Three.Vector3(0, 0, 0));
        scene.add(camera);
        return camera;
    }

    function render () {
        render.count = render.count || 0;
        if (render.count % 300 === 0) {
            grow = !grow;
        }
        render.count += 1;

        scene.traverse((child) => {
            if (child.name === SCULPTURE) {
                child.scale.multiplyScalar(grow ? SCALE : 1 / SCALE);
                child.rotation.y += ROTATE;
                child.material.color.setHex(Math.floor(Math.random() * FFFFFF));
            }
        });

        renderer.render(scene, camera);
        requestAnimationFrame(render);
    }
};

Sculpture.service('SceneService', SceneService);
