import 'dart:async';
import 'dart:convert';
import 'dart:convert' show utf8;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gl/flutter_gl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:nautic_viewer/data/parse/parse_spool.dart';
import 'package:three_dart/three3d/math/math.dart';
import 'package:three_dart/three_dart.dart' as three;
import 'package:three_dart_jsm/three_dart_jsm.dart' as three_jsm;

import '../connection/if_not_connection.dart';
import '../data/api/documents_services.dart';
import '../data/api/zipobject_services.dart';

class SimpleRender extends StatefulWidget {
  SimpleRender({Key? key, required this.url, required this.urlSpool})
      : super(key: key);

  String url;
  String urlSpool;

  @override
  State<SimpleRender> createState() => _SimpleRender();
}

class _SimpleRender extends State<SimpleRender> {
  List<String> spoolsList = List<String>.empty(growable: true);
  List<String> allSpoolsList = List<String>.empty(growable: true);
  List<DocData> futureSpool = List<DocData>.empty(growable: true);
  List<int> sqList = List<int>.empty(growable: true);

  final GlobalKey<three_jsm.DomLikeListenableState> _globalKey =
      GlobalKey<three_jsm.DomLikeListenableState>();

  late FlutterGlPlugin three3dRender;
  three.WebGLRenderer? renderer;
  late three.WebGLRenderTarget renderTarget;
  late three_jsm.OrbitControls controls;
  late three.AxesHelper axes;
  three.Object3D INTERSECTED = three.Object3D();

  late double width;
  late double height;

  Size? screenSize;

  late three.Scene scene;
  late three.Camera camera;

  late three.Group group;

  three.Box3 boundingBox = three.Box3();
  three.Box3 reBox = three.Box3();

  three.Raycaster raycaster = three.Raycaster();
  three.Vector2 pointer = three.Vector2();

  num aspect = 2.0;
  double dpr = 1.0;
  late int index;

  bool state = false;

  bool disposed = false;

  dynamic sourceTexture;

  var appBarHeight = 50.0;

  var localToCameraAxesPlacement;
  var data;
  var currentDocNumber;
  var currentSpool = "";

  @override
  void initState() {
    super.initState();
    data = getData(widget.urlSpool);
    currentSpool = data[1];
    currentDocNumber = data[0];

    parseSpool(currentDocNumber).then((value) => {
          if (value.item2 == "empty")
            {
              _dialogBuilder(context,
                  msg: "There is no data on the server for this query"),
            }
          else if (value.item2 == "failed")
            {
              _dialogBuilder(context,
                  msg:
                      "There is no connection to the deep-sea.ru server, maybe it is broken. \n\nPlease try again later"),
            },
          setState(() {
            value.item1.forEach((element) {
              spoolsList.add(element);
            });
          })
        });

    fetchDocument(currentDocNumber).then((value) => {
          if (value.item2 == "empty")
            {
              _dialogBuilder(context,
                  msg: "There is no data on the server for this query"),
            }
          else if (value.item2 == "failed")
            {
              _dialogBuilder(context,
                  msg:
                      "There is no connection to the deep-sea.ru server, maybe it is broken. \n\nPlease try again later"),
            },
          setState(() {
            value.item1.forEach((element) {
              futureSpool.add(element);
            });
          }),
          for (int i = 0; i < futureSpool.length; i++)
            {
              allSpoolsList.add(futureSpool[i].spool),
              sqList.add(futureSpool[i].sqInSystem)
            }
        });

    // SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
  }

  Future<void> _dialogBuilder(BuildContext context, {required String msg}) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Something wrong',
              style: TextStyle(fontSize: 26), maxLines: 1),
          content: Text(msg, style: TextStyle(fontSize: 20)),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Ok',
                  style: TextStyle(fontSize: 22), textAlign: TextAlign.center),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height -
        appBarHeight -
        MediaQuery.of(context).padding.top;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(appBarHeight),
          child: AppBar(
            title: Text("3D viewer"),
          ),
        ),
        body: SizedBox(
          width: width,
          height: height,
          child: state
              ? Builder(
                  builder: (BuildContext context) {
                    initSize(context);
                    return GestureDetector(
                      onDoubleTap: () {},
                      onDoubleTapDown: (details) => onPointer(details),
                      child: Container(
                        child: _build(context),
                      ),
                    );
                  },
                )
              : Builder(
                  builder: (BuildContext context) {
                    initSize(context);
                    return Container(
                      child: _build(context),
                    );
                  },
                ),
        ));
  }

  Widget _build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
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
                ? Container(
                    width: width,
                    height: height,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white54,
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(50),
                                bottomRight: Radius.circular(50)),
                          ),
                          child: SizedBox(
                            width: width,
                            height: height / 10.0,
                            child: Column(
                              children: <Widget>[
                                Text("Document: $currentDocNumber",
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.black),
                                    textAlign: TextAlign.center),
                                Text("Spool: $currentSpool",
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.black),
                                    textAlign: TextAlign.center),
                              ],
                            ),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 20),
                              height: width * 0.15,
                              width: width * 0.2,
                              child: IconButton(
                                onPressed: () => {setView(boundingBox)},
                                icon: Icon(Icons.center_focus_strong),
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.white54,
                                  primary: Colors.black,
                                  onSurface: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: height * 0.025,
                            )
                          ],
                        ),
                      ],
                    ),
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
          Positioned(
              child: CheckConnectionPage(
            page: Container(
              width: width,
              height: height,
            ),
          ))
        ],
      ),
    );
  }

  onPointer(details) {
    state = false;
    pointer.x = (details.globalPosition.dx / screenSize!.width) * 2 - 1;
    pointer.y = -(details.globalPosition.dy /
        (screenSize!.height +
            appBarHeight +
            MediaQuery.of(context).padding.top)) *
        2 +
        1;

    print(pointer.x);
    print(pointer.y);

    raycaster.setFromCamera(pointer, camera);
    var intersects = raycaster.intersectObjects(scene.children, true);

    if (intersects.isNotEmpty && intersects[0].object.name != "axes") {
      if (INTERSECTED != intersects[0].object) {
        scene.children.forEach((gr) => {
              if (gr.type == 'Group')
                {
                  gr.children.forEach((ch) => {
                        ch.children.forEach((mesh) {
                          mesh.material.color.set(0xffffff);
                        })
                      })
                }
            });
        print("defferent");
        INTERSECTED = intersects[0].object;

        for (var i = 0; i < intersects.length; i++) {
          intersects[0].object.material.color.set(0x9D7E7E);
          scaleView(intersects[0].object);
          // currentSpool = intersects[0].object.parent?.parent?.name;
        }
        print("hit");
      }
    }
    state = true;
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

    camera = three.PerspectiveCamera(50, aspect, 1, 100000);
    camera.position.set(-1, 1, 1);
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
    controls.maxDistance = 3000000;

    axes = three.AxesHelper(100000);
    axes.name = "axes";
    localToCameraAxesPlacement = controls.target;
    axes.rotation.x = -Math.PI / 2;
    scene.add(axes);

    controls.update();

    group = three.Group();

    loadObjFromZip("full");

    animate();
  }

  replaceObjScene(String name) {
    boundingBox = three.Box3();
    for (var i = scene.children.length - 1; i >= 0; i--) {
      var obj = scene.children[i];
      if (obj.type == 'Group') scene.remove(obj);
    }
    loadObjFromZip(name);
  }

  loadObjFromZip(String name) async {
    var loader = three_jsm.OBJLoader(null);

    await fetchFiles(widget.url).then((archive) => {
          // scene.clear(),
          setState(() {
            group = three.Group();
            group.name = name;
            print(group.name);
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
                          {scene.add(group), group.rotation.x = -Math.PI / 2}
                      });
            });
          })
        });

    fetchFiles(widget.urlSpool).then((archive) => {
          // scene.clear(),
          setState(() {
            group = three.Group();
            group.name = currentSpool;
            print(group.name);
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
                          {scene.add(group), createScaleView(group)}
                      });
            });
          })
        });
  }

  addToView(three.Object3D object) {
    object.rotation.x = -Math.PI / 2;
    boundingBox.expandByObject(object);
    setView(boundingBox);
  }

  scaleView(three.Object3D object) {
    reBox = three.Box3().setFromObject(object);
    setView(reBox);
  }

  createScaleView(three.Object3D object) {
    object.rotation.x = -Math.PI / 2;
    boundingBox.expandByObject(object);
    reBox = three.Box3().setFromObject(object);
    setView(reBox);
  }

  setView(three.Box3 box) {
    //boundingBox = three.Box3().setFromObject(object);

    scene.children.forEach((gr) => {
          if (gr.name == currentSpool)
            {
              gr.children.forEach((ch) => {
                    ch.children.forEach((mesh) {
                      mesh.material.color.set(0xFF0000);
                    })
                  })
            }
        });

    var center = three.Vector3();
    var size = three.Vector3();
    box.getCenter(center);
    box.getSize(size);

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
