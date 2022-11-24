import "package:flutter/material.dart";

import '../data/api/zipobject_services.dart';

class ScanData extends StatefulWidget {
  ScanData({Key? key, required this.url}) : super(key: key);

  String url;

  @override
  State<ScanData> createState() => _ScanDataState();
}

class _ScanDataState extends State<ScanData> {
  var data;
  var currentDocNumber;
  var currentSpool;

  late double width;
  late double height;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    data = getData(widget.url);
    currentDocNumber = data[0];
    currentSpool = data[1];
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    height = height - height * 0.1;

    return Container(
      alignment: Alignment.center,
      child: Column(
        children: <Widget>[
          // Text("Name: $currentDocNumber",
          //     style: TextStyle(fontSize: 24), textAlign: TextAlign.center),
          Text("SFI-drawing no.: $currentDocNumber",
              style: TextStyle(fontSize: 24), textAlign: TextAlign.center),
          SizedBox(
            height: height * 0.02,
          ),
          Text("Spool: $currentSpool",
              style: TextStyle(fontSize: 24), textAlign: TextAlign.center),
          // Text("Date: $currentSpool",
          //     style: TextStyle(fontSize: 24), textAlign: TextAlign.center),
          // Text("Rev.: $currentSpool",
          //     style: TextStyle(fontSize: 24), textAlign: TextAlign.center),
          // Text("Sheet.: $currentSpool",
          //     style: TextStyle(fontSize: 24), textAlign: TextAlign.center)
        ],
      ),
    );
  }
}
