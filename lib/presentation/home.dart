import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nautic_viewer/presentation/render.dart';

import '../data/api/zipobject_services.dart';
import '../internal/local_files.dart';
import '../internal/scandata.dart';
import 'documentfromscanner.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
    height = height - height * 0.1;

    return Scaffold(
      body: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/gradik_iz_ser.png"),
              fit: BoxFit.fill,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: height * 0.06,
                ),
                Container(
                    width: width * 0.55,
                    height: height * 0.15,
                    alignment: Alignment.bottomCenter,
                    child:
                        SvgPicture.asset("assets/NAUTIC_RUS_White_logo.svg")),
                SizedBox(
                  height: height * 0.06,
                ),
                Container(
                  padding: EdgeInsets.all(20),
                  width: width * 0.75,
                  height: height * 0.6,
                  decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.circular(50)),
                  alignment: Alignment.center,
                  child: !validateUrl(url)
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                              Text("Your last scan data",
                                  style: TextStyle(fontSize: 30),
                                  textAlign: TextAlign.center),
                              SizedBox(
                                height: height * 0.02,
                              ),
                              Image.asset(
                                "assets/not-found.png",
                                height: height * 0.2,
                                width: width * 0.2,
                              ),
                              SizedBox(
                                height: height * 0.02,
                              ),
                              Text("Data not found, use QR scanner",
                                  style: TextStyle(fontSize: 30),
                                  textAlign: TextAlign.center),
                            ])
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Text("Your last scan data",
                                style: TextStyle(fontSize: 30)),
                            SizedBox(
                              height: height * 0.02,
                            ),
                            ScanData(
                              url: url,
                            ),
                            SizedBox(
                              height: height * 0.02,
                            ),
                            SizedBox(
                                height: height * 0.07,
                                width: width * 0.7,
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ThreeRender(url: url)));
                                    });
                                  },
                                  child: Text("Display this spool"),
                                  style: ElevatedButton.styleFrom(
                                      textStyle: TextStyle(fontSize: 20)),
                                )),
                            SizedBox(
                              height: height * 0.02,
                            ),
                            SizedBox(
                                height: height * 0.07,
                                width: width * 0.7,
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  Document(url: url)));
                                    });
                                  },
                                  child: Text("Document information"),
                                  style: ElevatedButton.styleFrom(
                                      textStyle: TextStyle(fontSize: 20)),
                                )),
                          ],
                        ),
                ),
                SizedBox(
                  height: height * 0.02,
                ),
              ],
            ),
          )),
    );
  }
}
