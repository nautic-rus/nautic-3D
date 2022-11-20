import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../data/api/zipobject_services.dart';
import '../internal/local_files.dart';
import '../internal/scandata.dart';

class NoConnectionHome extends StatefulWidget {
  const NoConnectionHome({Key? key}) : super(key: key);

  @override
  State<NoConnectionHome> createState() => _NoConnectionHomeState();
}

class _NoConnectionHomeState extends State<NoConnectionHome> {
  String url = "";
  late Future<dynamic> urlFuture = getLastScanUrl();
  late double width;
  late double height;
  late double unitHeightValue;
  late double multiplier;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    urlFuture.then((value) => setState(() {
          url = value;
        }));
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/gradik_iz_ser.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: <Widget>[
                Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: MediaQuery.of(context).size.height * 0.2,
                    margin:
                        EdgeInsets.all(MediaQuery.of(context).size.width * 0.1),
                    alignment: Alignment.bottomCenter,
                    child:
                        SvgPicture.asset("assets/NAUTIC_RUS_White_logo.svg")),
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.15,
                  alignment: Alignment.center,
                  child: Text(
                    "No internet connection, application features are limited",
                    style: TextStyle(fontSize: 22),
                    textAlign: TextAlign.center,
                  ),
                  decoration: BoxDecoration(
                      color: Colors.red.shade300,
                      borderRadius: BorderRadius.circular(50)),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.3,
                  margin:
                      EdgeInsets.all(MediaQuery.of(context).size.width * 0.1),
                  decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.circular(50)),
                  alignment: Alignment.center,
                  child: !validateUrl(url)
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                              FittedBox(
                                child: Text("   Your last scan data    ",
                                    style: TextStyle(fontSize: 30),
                                    textAlign: TextAlign.center),
                                fit: BoxFit.cover,
                              ),
                              Image.asset(
                                "assets/not-found.png",
                                height: height * 0.2,
                                width: width * 0.2,
                              ),
                              FittedBox(
                                child: Text(
                                    "   Data not found, use QR scanner    ",
                                    style: TextStyle(fontSize: 30),
                                    textAlign: TextAlign.center),
                                fit: BoxFit.cover,
                              ),
                            ])
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Text("Your last scan data",
                                style: TextStyle(fontSize: 24)),
                            ScanData(
                              url: url,
                            ),
                          ],
                        ),
                ),
                SizedBox(
                  height: height * 0.05, // <-- SEE HERE
                ),
              ],
            ),
          )),
    );
  }
}
