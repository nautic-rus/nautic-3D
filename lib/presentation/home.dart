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
                  height: MediaQuery.of(context).size.height * 0.5,
                  margin:
                      EdgeInsets.all(MediaQuery.of(context).size.width * 0.1),
                  decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.circular(50)),
                  alignment: Alignment.center,
                  child: !validateUrl(url)
                      ?  Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                              Text("Your last scan data",
                                  style: TextStyle(fontSize: 24)),
                              Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.3,
                                  child: Image(
                                      image:
                                          AssetImage("assets/not-found.png"))),
                              Text("Data not found, use QR scanner",
                                  style: TextStyle(fontSize: 22),
                                  textAlign: TextAlign.center)
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
                                height:
                                    MediaQuery.of(context).size.height * 0.07,
                                width: MediaQuery.of(context).size.width * 0.7,
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
                                height:
                                    MediaQuery.of(context).size.height * 0.07,
                                width: MediaQuery.of(context).size.width * 0.7,
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
                                ))
                          ],
                        ),
                ),
              ],
            ),
          )),
    );
  }
}
