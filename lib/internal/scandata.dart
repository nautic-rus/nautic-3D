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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text("Document:\n $currentDocNumber",
                style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
            Text("Spool:\n $currentSpool",
                style: TextStyle(fontSize: 16), textAlign: TextAlign.center)
          ],
        ),
        Image.asset(
          "assets/qr.png",
          width: MediaQuery.of(context).size.width * 0.2,
          height: MediaQuery.of(context).size.width * 0.2,
        )
      ],
    );
  }
}
