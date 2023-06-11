import 'package:auto_size_text/auto_size_text.dart';
import "package:flutter/material.dart";
import 'package:flutter/scheduler.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../data/api/documents_services.dart';
import '../../data/api/zipobject_services.dart';
import '../../data/parse/parse_doc.dart';

class ScanData extends StatefulWidget {
  ScanData(
      {Key? key,
      required this.futureDocs,
      required this.data,
      required this.connectionState})
      : super(key: key);

  List<DocData> futureDocs;
  List data;
  String connectionState;

  @override
  State<ScanData> createState() => _ScanDataState();
}

class _ScanDataState extends State<ScanData> {
  List<String> spoolsList = List<String>.empty(growable: true);

  var currentDocNumber;
  var currentSpool;
  var systemDescr;
  var line;

  var brightness;

  late double width;
  late double height;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    currentDocNumber = widget.data[0];
    currentSpool = widget.data[1];
    print(currentSpool);

    setState(() {
      for (int i = 0; i < widget.futureDocs.length; i++) {
        if (widget.futureDocs[i].spool == currentSpool) {
          systemDescr = getSystemDescr(widget.futureDocs[i].systemDescr);
          line = widget.futureDocs[i].line;
        }
      }
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
        child: widget.connectionState == "connect"
            ? systemDescr != null
                ? Column(
                    children: <Widget>[
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
                : Column(
                    children: <Widget>[
                      AutoSizeText(
                          "There is no data on the server for this document",
                          style:
                              TextStyle(fontSize: 22, color: Colors.redAccent),
                          maxLines: 3,
                          textAlign: TextAlign.center),
                      SizedBox(
                        height: height * 0.01,
                      ),
                    ],
                  )
            : widget.connectionState == "empty"
                ? Column(
                    children: <Widget>[
                      AutoSizeText(
                          "There is no data on the server for this document",
                          style:
                              TextStyle(fontSize: 22, color: Colors.redAccent),
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
                      AutoSizeText(
                          "No connection to the server, maybe it is broken",
                          style:
                              TextStyle(fontSize: 22, color: Colors.redAccent),
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
