import 'package:auto_size_text/auto_size_text.dart';
import "package:flutter/material.dart";
import 'package:flutter/scheduler.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../data/api/documents_services.dart';
import '../../data/api/zipobject_services.dart';
import '../../data/parse/parse_doc.dart';

class ScanData extends StatefulWidget {
  ScanData({Key? key, required this.url}) : super(key: key);

  String url;

  @override
  State<ScanData> createState() => _ScanDataState();
}

class _ScanDataState extends State<ScanData> {
  List<DocData> futureSpool = List<DocData>.empty(growable: true);
  List<String> spoolsList = List<String>.empty(growable: true);

  var data;
  var currentDocNumber;
  var currentSpool;
  var systemDescr;
  var line;

  var brightness;

  String connectionState = "connect";

  late double width;
  late double height;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    data = getData(widget.url);
    currentDocNumber = data[0];
    currentSpool = data[1];
    print(currentSpool);

    fetchDocument(currentDocNumber).then((value) => {
          setState(() {
            connectionState = value.item2;
            value.item1.forEach((element) {
              futureSpool.add(element);
            });

            for (int i = 0; i < futureSpool.length; i++) {
              if (futureSpool[i].spool == currentSpool) {
                systemDescr = getSystemDescr(futureSpool[i].systemDescr);
                line = futureSpool[i].line;
              }
            }
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    height = height - height * 0.1;
    brightness = SchedulerBinding.instance.window.platformBrightness;

    return Container(
        alignment: Alignment.center,
        child: connectionState == "connect"
            ? systemDescr == null
                ? isLoading()
                : Column(
                    children: <Widget>[
                      // Text("Name: $currentDocNumber",
                      //     style: TextStyle(fontSize: 24), textAlign: TextAlign.center),
                      AutoSizeText("Name:\n$systemDescr",
                          style: TextStyle(fontSize: 22),
                          maxLines: 3,
                          textAlign: TextAlign.center),
                      SizedBox(
                        height: height * 0.01,
                      ),
                      AutoSizeText("SFI-drawing no.:\n$currentDocNumber",
                          style: TextStyle(fontSize: 22),
                          maxLines: 2,
                          textAlign: TextAlign.center),
                      SizedBox(
                        height: height * 0.01,
                      ),
                      AutoSizeText("Spool: $currentSpool",
                          style: TextStyle(fontSize: 22),
                          maxLines: 1,
                          textAlign: TextAlign.center),
                      SizedBox(
                        height: height * 0.01,
                      ),
                      AutoSizeText("Line: $line",
                          style: TextStyle(fontSize: 22),
                          maxLines: 1,
                          textAlign: TextAlign.center),
                    ],
                  )
            : connectionState == "empty"
                ? Column(
                    children: <Widget>[
                      AutoSizeText(
                          "There is no data on the server for this query",
                          style: TextStyle(fontSize: 22),
                          maxLines: 3,
                          textAlign: TextAlign.center),
                      SizedBox(
                        height: height * 0.01,
                      ),
                      AutoSizeText("SFI-drawing no.:\n$currentDocNumber",
                          style: TextStyle(fontSize: 22),
                          maxLines: 2,
                          textAlign: TextAlign.center),
                      SizedBox(
                        height: height * 0.01,
                      ),
                      AutoSizeText("Spool: $currentSpool",
                          style: TextStyle(fontSize: 22),
                          maxLines: 1,
                          textAlign: TextAlign.center),
                    ],
                  )
                : Column(
                    children: <Widget>[
                      AutoSizeText("No connection to the server, maybe it is broken",
                          style: TextStyle(fontSize: 22, color: Colors.red),
                          maxLines: 3,
                          textAlign: TextAlign.center),
                      SizedBox(
                        height: height * 0.01,
                      ),
                      AutoSizeText("SFI-drawing no.:\n$currentDocNumber",
                          style: TextStyle(fontSize: 22),
                          maxLines: 2,
                          textAlign: TextAlign.center),
                      SizedBox(
                        height: height * 0.01,
                      ),
                      AutoSizeText("Spool: $currentSpool",
                          style: TextStyle(fontSize: 22),
                          maxLines: 1,
                          textAlign: TextAlign.center),
                    ],
                  ));
  }

  Widget isLoading() {
    return Center(
        child: LoadingAnimationWidget.threeArchedCircle(
            color: brightness == Brightness.dark
                ? Color(0xFF67CAD7)
                : Color(0xFF2C298A),
            size: MediaQuery.of(context).size.width * 0.2));
  }
}
