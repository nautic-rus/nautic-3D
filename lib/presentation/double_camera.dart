import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three3d/math/math.dart';
import 'package:three_dart/three_dart.dart' as three;
import 'package:three_dart_jsm/three_dart_jsm.dart' as three_jsm;

class WebGlCamera extends StatefulWidget {
  const WebGlCamera({Key? key}) : super(key: key);

  @override
  State<WebGlCamera> createState() => _MyAppState();
}

class _MyAppState extends State<WebGlCamera> {
  late FlutterGlPlugin three3dRender;
  three.WebGLRenderer? renderer;

  int? fboId;
  late double width;
  late double height;

  Size? screenSize;

  late three.Scene scene;
  late three.Camera camera;
  late three.Mesh mesh;

  late three.Camera cameraPerspective;
  late three.Camera cameraOrtho;

  late three.Group cameraRig;

  late three.Camera activeCamera;
  late three.CameraHelper activeHelper;

  late three.CameraHelper cameraOrthoHelper;
  late three.CameraHelper cameraPerspectiveHelper;

  final GlobalKey<three_jsm.DomLikeListenableState> _globalKey =
  GlobalKey<three_jsm.DomLikeListenableState>();

  late three_jsm.TrackballControls controls;
  late three_jsm.OrbitControls axesControls;

  int frustumSize = 600;

  double dpr = 1.0;

  num aspect = 2.0;

  var amount = 4;

  var appBarHeight = 50.0;

  var geometry, material, axisHelper, localToCameraAxesPlacement;


  late three.Mesh cube;

  late three.AxesHelper axes;
  late three.AxesHelper axes2;

  bool verbose = true;
  bool disposed = false;

  late three.WebGLRenderTarget renderTarget;

  dynamic sourceTexture;

  get document => null;

  @override
  void initState() {
    super.initState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    width = screenSize!.width;
    height =
        screenSize!.height - appBarHeight - MediaQuery
            .of(context)
            .padding
            .top;

    three3dRender = FlutterGlPlugin();

    Map<String, dynamic> options = {
      "antialias": true,
      "alpha": false,
      "width": width.toInt(),
      "height": height.toInt(),
      "dpr": dpr
    };

    await three3dRender.initialize(options: options);

    setState(() {});

    // Wait for web
    Future.delayed(const Duration(milliseconds: 100), () async {
      await three3dRender.prepareContext();

      initScene();
    });
  }

  initSize(BuildContext context) {
    if (screenSize != null) {
      return;
    }

    final mqd = MediaQuery.of(context);

    screenSize = mqd.size;
    dpr = mqd.devicePixelRatio;

    initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: AppBar(
          title: Text("render"),
        ),
      ),
      body: Builder(
        builder: (BuildContext context) {
          initSize(context);
          return Container(
            child: _build(context),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Text("render"),
        onPressed: () {
          render();
        },
      ),
    );
  }

  Widget _build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            three_jsm.DomLikeListenable(
                key: _globalKey,
                builder: (BuildContext context) {
                  return Container(
                      width: width,
                      height: height,
                      color: Colors.black,
                      child: Builder(builder: (BuildContext context) {
                        if (kIsWeb) {
                          return three3dRender.isInitialized
                              ? HtmlElementView(
                              viewType: three3dRender.textureId!.toString())
                              : Container();
                        } else {
                          return three3dRender.isInitialized
                              ? Texture(textureId: three3dRender.textureId!)
                              : Container();
                        }
                      }));
                }),
          ],
        ),
      ],
    );
  }

  render() {
    final gl = three3dRender.gl;

    // camera.lookAt(mesh.position);

    camera.updateMatrixWorld();
    var axesPlacement = camera.localToWorld(localToCameraAxesPlacement.clone());
    axisHelper.position.copy(axesPlacement);

    renderer?.render(scene, camera);

    gl.flush();

    if (!kIsWeb) {
      three3dRender.updateTexture(sourceTexture);
    }
  }

  initRenderer() {
    Map<String, dynamic> options = {
      "width": width,
      "height": height,
      "gl": three3dRender.gl,
      "antialias": true,
      "canvas": three3dRender.element
    };

    renderer = three.WebGLRenderer(options);
    renderer!.setPixelRatio(dpr);
    renderer!.setSize(width, height, false);
    renderer!.shadowMap.enabled = false;
    renderer!.autoClear = true;

    if (!kIsWeb) {
      var pars = three.WebGLRenderTargetOptions({
        "minFilter": three.LinearFilter,
        "magFilter": three.LinearFilter,
        "format": three.RGBAFormat,
        "samples": 4
      });
      renderTarget = three.WebGLRenderTarget(
          (width * dpr).toInt(), (height * dpr).toInt(), pars);
      renderer!.setRenderTarget(renderTarget);

      sourceTexture = renderer!.getRenderTargetGLTexture(renderTarget);
    }
  }

  initScene() {
    initRenderer();
    initPage();
  }

  initPage() async {
    aspect = width / height;

    scene = three.Scene();

    camera = three.PerspectiveCamera(50, aspect, 1, 10000);
    camera.position.z = 500;
    scene.add(camera);

    axisHelper = three.AxesHelper(0.2);
    localToCameraAxesPlacement = three.Vector3(-0.5 * camera.aspect, -0.75,
        -2); // make sure to update this on window resize
    scene.add(axisHelper);

    geometry = three.BoxGeometry(200, 200, 200, 1, 1, 1);
    material = three.MeshNormalMaterial();

    mesh = three.Mesh(geometry, material);
    scene.add(mesh);

    axesControls = three_jsm.OrbitControls(camera, _globalKey);

    axesControls.update();

    animate();
  }

  animate() {
    if (!mounted || disposed) {
      return;
    }

    render();

    Future.delayed(const Duration(milliseconds: 10), () {
      animate();
    });
  }

  @override
  void dispose() {
    print(" dispose ............. ");

    disposed = true;
    three3dRender.dispose();

    super.dispose();
  }
}
