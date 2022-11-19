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
                SizedBox(
                  height: height * 0.05, // <-- SEE HERE
                ),
                Container(
                    width: width * 0.55,
                    height: height * 0.2,
                    alignment: Alignment.bottomCenter,
                    child:
                        SvgPicture.asset("assets/NAUTIC_RUS_White_logo.svg")),
                SizedBox(
                  height: height * 0.1, // <-- SEE HERE
                ),
                FittedBox(
                  fit: BoxFit.cover,
                  child: Container(
                    width: width * 0.75,
                    height: height * 0.5,
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
                                  child: Text("   Data not found, use QR scanner    ",
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
                              SizedBox(
                                height: height * 0.05, // <-- SEE HERE
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
