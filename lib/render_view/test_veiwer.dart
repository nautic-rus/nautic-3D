import 'dart:async';
import 'dart:convert';
import 'dart:convert' show utf8;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gl/flutter_gl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:nautic_viewer/data/parse/parse_spool.dart';
import 'package:three_dart/three3d/math/math.dart';
import 'package:three_dart/three_dart.dart' as three;
import 'package:three_dart_jsm/three_dart_jsm.dart' as three_jsm;

import '../data/api/zipobject_services.dart';

class RayCast extends StatefulWidget {
  RayCast({Key? key, required this.url}) : super(key: key);

  String url;

  @override
  State<RayCast> createState() => _RayCast();
}

class _RayCast extends State<RayCast> {
  List<String> spoolsList = List<String>.empty(growable: true);

  final GlobalKey<three_jsm.DomLikeListenableState> _globalKey =
      GlobalKey<three_jsm.DomLikeListenableState>();

  late FlutterGlPlugin three3dRender;
  three.WebGLRenderer? renderer;
  late three.WebGLRenderTarget renderTarget;
  late three_jsm.OrbitControls controls;
  late three.AxesHelper axes;

  late three.EventDispatcher event;

  late double width;
  late double height;

  Size? screenSize;

  three.Raycaster raycaster = three.Raycaster();
  three.Vector2 pointer = three.Vector2();

  late three.Scene scene;
  late three.Camera camera;

  late three.Group group;

  three.Box3 boundingBox = three.Box3();

  num aspect = 2.0;
  double dpr = 1.0;
  late int index;

  bool state = false;

  bool disposed = false;

  dynamic sourceTexture;

  var appBarHeight = 50.0;

  var localToCameraAxesPlacement;
  var data;
  late int currentSpoolIndex;
  var currentSpool;
  var currentDocNumber;
  late int nextSpoolIndex;
  late int previousSpoolIndex;
  var addingSpool;

  late Offset _tapPosition;

  @override
  void initState() {
    super.initState();
    data = getData(widget.url);
    currentDocNumber = data[0];
    currentSpool = data[1];
    addingSpool = currentSpool;

    parseSpool(currentDocNumber).then((value) => {
          setState(() {
            value.item1.forEach((element) {
              spoolsList.add(element);
            });
            currentSpoolIndex = spoolsList.indexOf(currentSpool);
            nextSpoolIndex = currentSpoolIndex;
            previousSpoolIndex = currentSpoolIndex;

            print(spoolsList);
            print("Current spool index is $currentSpoolIndex");
          })
        });

    // SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () {},
      onDoubleTapDown: (details) => onPointer(details),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(appBarHeight),
          child: AppBar(
            title: Text("Test"),
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
                      color: Colors.white,
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
            Positioned(
              child: state
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: width,
                          height: height / 10.0,
                          child: Column(
                            children: <Widget>[
                              Text("Document: $currentDocNumber"),
                              Text("Spool: $currentSpool"),
                              Text("Adding spool: $addingSpool")
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            SizedBox(
                                height: height * 4.5 / 10.0,
                                width: width * 0.1,
                                child: TextButton(
                                  onPressed: () => previousSpool(),
                                  child: RotatedBox(
                                    quarterTurns: 1,
                                    child: Text("Previous"),
                                  ),
                                  style: TextButton.styleFrom(
                                    primary: Colors.black,
                                    onSurface: Colors.white,
                                  ),
                                )),
                            SizedBox(
                                height: height * 4.5 / 10.0,
                                width: width * 0.1,
                                child: TextButton(
                                  onPressed: () => nextSpool(),
                                  child: RotatedBox(
                                    quarterTurns: 1,
                                    child: Text("Next"),
                                  ),
                                  style: TextButton.styleFrom(
                                    primary: Colors.black,
                                    onSurface: Colors.white,
                                  ),
                                )),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            SizedBox(
                                height: height * 4.5 / 10.0,
                                width: width * 0.1,
                                child: TextButton(
                                  onPressed: () => addPreviousSpool(),
                                  child: RotatedBox(
                                    quarterTurns: 1,
                                    child: Text("Add previous"),
                                  ),
                                  style: TextButton.styleFrom(
                                    primary: Colors.black,
                                    onSurface: Colors.white,
                                  ),
                                )),
                            SizedBox(
                                height: height * 4.5 / 10.0,
                                width: width * 0.1,
                                child: TextButton(
                                  onPressed: () => addNextSpool(),
                                  child: RotatedBox(
                                    quarterTurns: 1,
                                    child: Text("Add next"),
                                  ),
                                  style: TextButton.styleFrom(
                                    primary: Colors.black,
                                    onSurface: Colors.white,
                                  ),
                                )),
                          ],
                        )
                      ],
                    )
                  : Container(
                      width: width,
                      height: height,
                      color: Colors.grey.shade600.withOpacity(0.5),
                      child: LoadingAnimationWidget.threeArchedCircle(
                          color: Colors.white,
                          size: MediaQuery.of(context).size.width * 0.2),
                    ),
            ),
          ],
        ),
      ],
    );
  }

  // onPointerMove(details) {
  //
  //   setState(() {
  //     print("double tap");
  //     pointer.x = (details.globalPosition.dx / width) * 2.0 -1;
  //     pointer.y = -(details.globalPosition.dy / height) * 2.0 + 1;
  //     print("${pointer.x}");
  //     print("${pointer.y}");
  //     render(ev: "double tap");
  //   });
  // }

  onPointer(details) {
    var x = (details.globalPosition.dx / screenSize!.width) * 2 - 1.1;
    var y = -(details.globalPosition.dy / screenSize!.height) * 2 + 1.1;
    var dir = three.Vector3(x, y);
    print(x);
    print(y);
    dir.unproject(camera);

    var ray =
        three.Raycaster(camera.position, dir.sub(camera.position).normalize());
    var intersects = ray.intersectObjects(scene.children, true);

    if (intersects.isNotEmpty) {
      print("hit");
      for (var i = 0; i < intersects.length; i++) {
        intersects[0].object.material.color.set(0xff0000);
      }
    }
  }

  nextSpool() {
    setState(() {
      state = false;
      currentSpoolIndex = checkNextSpool(++currentSpoolIndex);
      print(currentSpoolIndex);
      data[1] = spoolsList[currentSpoolIndex];
      if (currentSpool != data[1]) {
        currentSpool = data[1];
        nextSpoolIndex = currentSpoolIndex;
        previousSpoolIndex = currentSpoolIndex;
        addingSpool = currentSpool;
        widget.url = getUrl(data);
        replaceObjScene();
        print(widget.url);
      } else {
        state = true;
      }
    });
  }

  previousSpool() {
    setState(() {
      state = false;
      currentSpoolIndex = checkPreviousSpool(--currentSpoolIndex);
      print(currentSpoolIndex);
      data[1] = spoolsList[currentSpoolIndex];
      if (currentSpool != data[1]) {
        currentSpool = data[1];
        nextSpoolIndex = currentSpoolIndex;
        previousSpoolIndex = currentSpoolIndex;
        addingSpool = currentSpool;
        widget.url = getUrl(data);
        replaceObjScene();
        print(widget.url);
      } else {
        state = true;
      }
    });
  }

  addNextSpool() {
    setState(() {
      state = false;
      nextSpoolIndex = checkNextSpool(++nextSpoolIndex);
      print(nextSpoolIndex);
      data[1] = spoolsList[nextSpoolIndex];
      if (addingSpool != data[1]) {
        addingSpool = data[1];
        widget.url = getUrl(data);
        addObjScene();
        print(widget.url);
      } else {
        state = true;
      }
    });
  }

  addPreviousSpool() {
    setState(() {
      state = false;
      previousSpoolIndex = checkPreviousSpool(--previousSpoolIndex);
      print(previousSpoolIndex);
      data[1] = spoolsList[previousSpoolIndex];
      if (addingSpool != data[1]) {
        addingSpool = data[1];
        widget.url = getUrl(data);
        addObjScene();
        print(widget.url);
      } else {
        state = true;
      }
    });
  }

  checkNextSpool(int index) {
    if (index == spoolsList.length) index = spoolsList.length - 1;
    return index;
  }

  checkPreviousSpool(int index) {
    if (index < 0) index = 0;
    return index;
  }

  void _showToast(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: const Text('Added to favorite'),
        action: SnackBarAction(
            label: 'UNDO', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
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

  render({String ev = ""}) {
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
    camera.position.set(0, -1, 0);
    scene.add(camera);
    scene.background = three.Color(0xA6A6A6);

    // soft white light
    var ambientLight = three.AmbientLight(0x404040, 100);
    ambientLight.intensity = 3;
    scene.add(ambientLight);

    var directionalLight = three.DirectionalLight(0xffffff, 0.3);
    scene.add(directionalLight);

    controls = three_jsm.OrbitControls(camera, _globalKey);

    controls.enableDamping = true;
    controls.dampingFactor = 0.25;
    controls.enableZoom = true;

    controls.minDistance = 10;
    controls.maxDistance = 30000;

    axes = three.AxesHelper(100000);
    localToCameraAxesPlacement = controls.target;
    scene.add(axes);

    controls.update();

    group = three.Group();

    loadObjFromZip();

    animate();
  }

  addObjScene() {
    loadObjFromZip();
  }

  replaceObjScene() {
    boundingBox = three.Box3();
    for (var i = scene.children.length - 1; i >= 0; i--) {
      var obj = scene.children[i];
      if (obj.type == 'Group') scene.remove(obj);
    }
    loadObjFromZip();
  }

  loadObjFromZip() {
    var loader = three_jsm.OBJLoader(null);
    bool first = true;

    fetchFiles([]).then((archive) => {
          // scene.clear(),
          setState(() {
            group = three.Group();
            var archiveFiles = 0;
            archive.item1.files.forEach((file) {
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
                        if (++archiveFiles == archive.item1.files.length)
                          {scene.add(group), setView(group)}
                      });
            });
          })
        });
  }

  setView(three.Object3D object) {
    boundingBox.expandByObject(object);

    //boundingBox = three.Box3().setFromObject(object);

    var center = three.Vector3();
    var size = three.Vector3();
    boundingBox.getCenter(center);
    boundingBox.getSize(size);

    var fitOffset = 1.2;
    var maxSize = Math.max(size.x, Math.max(size.y, size.z));
    var fitHeightDistance =
        maxSize / (2 * Math.atan(Math.pi * camera.fov / 360));
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

    controls.update();

    setState(() {
      state = true;
    });
    // axesControls.update();
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
}
