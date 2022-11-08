import 'dart:async';
import 'dart:convert';
import 'dart:convert' show utf8;

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three3d/math/math.dart';
import 'package:three_dart/three_dart.dart' as three;
import 'package:three_dart_jsm/three_dart_jsm.dart' as three_jsm;

import 'api.dart';

class ThreeRender extends StatefulWidget {
  const ThreeRender({Key? key, required this.url}) : super(key: key);

  final String url;

  @override
  State<ThreeRender> createState() => _ThreeRender();
}

class _ThreeRender extends State<ThreeRender> {
  List<ArchiveFile> objectFiles = List<ArchiveFile>.empty(growable: true);

  late FlutterGlPlugin three3dRender;
  three.WebGLRenderer? renderer;

  int? fboId;
  late double width = MediaQuery.of(context).size.height * 0.5;
  late double height = MediaQuery.of(context).size.width * 0.5;

  Size? screenSize;

  late three.Scene scene;
  late three.Camera camera;

  var appBarHeight = 50.0;

  num aspect = 2.0;

  double dpr = 1.0;

  bool verbose = true;
  bool disposed = false;

  late three.WebGLRenderTarget renderTarget;

  dynamic sourceTexture;

  final GlobalKey<three_jsm.DomLikeListenableState> _globalKey =
  GlobalKey<three_jsm.DomLikeListenableState>();

  late three_jsm.OrbitControls controls;
  var localToCameraAxesPlacement;

  late three.AxesHelper axes;

  @override
  void initState() {
    super.initState();
    // SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    width = screenSize!.width;
    height =
        screenSize!.height - appBarHeight - MediaQuery.of(context).padding.top;

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

    Future.delayed(const Duration(milliseconds: 10), () async {
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

    camera.updateMatrixWorld();
    var axesPlacement = localToCameraAxesPlacement.clone();
    axes.position.copy(axesPlacement);

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
      renderTarget.samples = 4;
      renderer!.setRenderTarget(renderTarget);
      sourceTexture = renderer!.getRenderTargetGLTexture(renderTarget);
    }
  }

  initScene() {
    initRenderer();
    initPage();
  }

  initPage() async {
    // create the scene
    aspect = width / height;

    scene = three.Scene();

    camera = three.PerspectiveCamera(50, aspect, 1, 10000);
    camera.position.z = 1000;

    scene.add(camera);

    scene.background = three.Color(0x808080);

    // soft white light
    var ambientLight = three.AmbientLight(0x404040);
    ambientLight.intensity = 3;
    scene.add(ambientLight);

    var directionalLight = three.DirectionalLight(0xffffff, 0.3);
    scene.add(directionalLight);

    controls = three_jsm.OrbitControls(camera, _globalKey);

    axes = three.AxesHelper(0.1);
    localToCameraAxesPlacement = three.Vector3(-0.5 * camera.aspect, -0.75, -2);
    scene.add(axes);

    controls.minDistance = 10;
    controls.maxDistance = 30000;

    controls.update();

    animate();

    var loader = three_jsm.OBJLoader(null);
    bool first = true;

    // three.Object3D object;

    // object = await loader.loadAsync('assets/megahull.obj');
    // scene.add(object);
    // setView(object);
    // animate();

    fetchFiles(widget.url).then((archive) => {
      setState(() {
        var group = three.Group();
        var archiveFiles = 0;
        archive.files.forEach((file) {
          var decode = utf8.decode(file.content);
          List<String> split;
          List<String> formatted = List.empty(growable: true);
          decode.split('\n').forEach((line) => {
            split = line.split(' '),
            if (split.isNotEmpty && split.elementAt(0) == 'v')
              {formatted.add(line)}
            else if (split.isNotEmpty && split.elementAt(0) == 'f')
              {
                formatted.add(List.from([
                  'f',
                  split.elementAt(1).replaceAll("/", "//"),
                  split.elementAt(2).replaceAll("/", "//"),
                  split.elementAt(3).replaceAll("/", "//")
                ]).join(' ')),
              }
            else if (line.trim() == "")
                {}
              else
                {formatted.add(line)}
          });

          (loader.parse(formatted.join('\n')) as Future<dynamic>)
              .then((model) => {
            group.add(model),
            if (++archiveFiles == archive.files.length)
              {scene.add(group), setView(group), animate()}
          });
        });
      })
    });

    // scene.addEventListener('resize', initPlatformState);
    //
    // controls.touches = {
    //   'ONE': three.TOUCH.ROTATE,
    //   'TWO': three.TOUCH.DOLLY_PAN
    // };
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

    // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    super.dispose();
  }

  setView(three.Object3D object) {
    var boundingBox = three.Box3().setFromObject(object);

    var center = three.Vector3();
    var size = three.Vector3();
    boundingBox.getCenter(center);
    boundingBox.getSize(size);

    var fitOffset = 1.2;
    var maxSize = Math.max(size.x, Math.max(size.y, size.z));
    var fitHeightDistance =
        maxSize / (2 * Math.atan(Math.PI * camera.fov / 360));
    var fitWidthDistance = fitHeightDistance / camera.aspect;
    var distance = fitOffset * Math.max(fitHeightDistance, fitWidthDistance);

    var direction = controls.target
        .clone()
        .sub(camera.position)
        .normalize()
        .multiplyScalar(distance);

    controls.maxDistance = distance * 10;
    controls.target.copy(center);

    camera.near = distance / 100;
    camera.far = distance * 100;
    camera.updateProjectionMatrix();

    camera.position.copy(controls.target).sub(direction);

    axes = three.AxesHelper(camera.far);
    localToCameraAxesPlacement = controls.target;
    scene.add(axes);

    controls.update();
    // axesControls.update();
  }
}
