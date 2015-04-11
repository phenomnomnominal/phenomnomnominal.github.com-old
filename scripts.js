var gl = supportsWebGL();
var renderer = gl ? new THREE.WebGLRenderer() : new THREE.CanvasRenderer();
var camera = new THREE.PerspectiveCamera(45, 1, 0.1, 10000);
var scene = new THREE.Scene();

camera.position.set(400,0,0);
camera.lookAt(new THREE.Vector3(0,0,0));
scene.add(camera);

var $container = document.querySelector('#skull');
$container.appendChild(renderer.domElement);

var skullModel;
var loader = new THREE.JSONLoader();
loader.load('skull.json', function ( geometry ) {
    skullModel = new THREE.Mesh(geometry, new THREE.MeshBasicMaterial({
        wireframe: true,
        wireframeLinewidth: 2.5
    }));
    skullModel.scale.multiplyScalar(125);
    scene.add(skullModel);
});

window.addEventListener('resize', resize);
resize();

var scale = 1.001;
var grow = true;
var count = 0;
render();

function resize () {
    var width = parseFloat(window.getComputedStyle(document.body).width);
    renderer.setSize(width, width);
}

function render () {
    if (count % 300 === 0) {
        grow = !grow;
    }
    count += 1;
    
    if (skullModel) {
      skullModel.scale.multiplyScalar((grow ? scale : 1 / scale))
      skullModel.rotation.y += 0.01;
      skullModel.material.color.setHex(Math.floor(Math.random() * 16777215));
    }

    renderer.render(scene, camera);
    requestAnimationFrame(render);
}

function supportsWebGL() {
    try {
        return !!window.WebGLRenderingContext &&
            !!document.createElement('canvas').getContext('experimental-webgl');
    } catch(e) {
        return false;
    }
}
