import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../connection/check_connection.dart';
import '../../data/api/documents_services.dart';
import '../../data/api/issues_services.dart';
import '../../data/api/zipobject_services.dart';
import '../../internal/localfiles/local_files.dart';
import '../../internal/navigation/navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  List<DocData> futureDocs = List<DocData>.empty(growable: true);
  List<IssuesData> futureIssues = List<IssuesData>.empty(growable: true);

  bool isInternetAvailable = false;
  late double width;
  late double height;

  late String currentDocNumber;

  Timer? timer;

  var brightness;

  String connectionState = "connect";

  late Future<dynamic> urlFuture = getLastScanUrl();

  @override
  void initState() {
    super.initState();

    isInternetConnected().then((value) => setState(() {
          connectionState = value;
          print(connectionState);
          value == "connect" ? _loadingDataConnect() : _goToNavigation(context);
        }));

    Future.delayed(const Duration(seconds: 30), () {
      _goToNavigation(context);
    });
  }

  _setFetchIssues() async {
    await fetchIssues().then((value) {
      setState(() {
        connectionState = value.item2;
        value.item1.forEach((element) {
          futureIssues.add(element);
        });
        print(connectionState);
      });
    });
  }

  _loadingDataConnect() async {
    // await _setFetchDocument();
    await _setFetchIssues();
    await _goToNavigation(context);
  }

  _goToNavigation(BuildContext context) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => Navigation(
                  futureDocs: futureDocs,
                  futureIssues: futureIssues,
                  connectionState: connectionState
                )));
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    brightness = SchedulerBinding.instance.window.platformBrightness;
    print(brightness);
    return Scaffold(
        body: Stack(
      children: <Widget>[
        Center(
          child: Container(
              width: width * 0.7,
              height: height * 0.3,
              alignment: Alignment.center,
              child: brightness == Brightness.dark
                  ? SvgPicture.asset("assets/NAUTIC_RUS_White_logo.svg")
                  : SvgPicture.asset("assets/nautic_blue.svg")),
        ),
        Positioned(child: Container(
          width: width,
          height: height,
          alignment: Alignment.bottomCenter,
          padding: EdgeInsets.only(bottom: height * 0.1),
          child: isLoading(),
        ))
      ],
    ));
  }

  Widget isLoading() {
    return LoadingAnimationWidget.threeArchedCircle(
        color: brightness == Brightness.dark
            ? Color(0xFF67CAD7)
            : Color(0xFF2C298A),
        size: MediaQuery.of(context).size.height * 0.05);
  }
}
