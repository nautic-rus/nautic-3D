import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:nautic_viewer/render_view/main_viewer.dart';
import 'package:nautic_viewer/presentation/datascreens/list_spools.dart';
import 'package:nautic_viewer/render_view/simple_viewer.dart';

import '../../data/api/zipobject_services.dart';
import '../../internal/comp_data/document_info.dart';
import '../../connection/if_not_connection.dart';

class Document extends StatefulWidget {
  Document({Key? key, required this.url}) : super(key: key);

  String url;

  @override
  State<Document> createState() => _DocumentState();
}

class _DocumentState extends State<Document> {
  var data;
  var currentDocNumber;
  var currentSpool;
  bool isInternetAvailable = true;

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
    return data.isEmpty
        ? Scaffold(
            body: Center(
                child: LoadingAnimationWidget.threeArchedCircle(
                    color: Color.fromARGB(255, 119, 134, 233),
                    size: MediaQuery.of(context).size.width * 0.2)),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text("Document"),
            ),
            body: CheckConnectionPage(
              page: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(alignment: Alignment.center, padding: EdgeInsets.symmetric(horizontal: 10), child: ScanData(url: widget.url)),
                  SizedBox(
                      height: MediaQuery.of(context).size.height * 0.07,
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    ThreeRender(url: widget.url)));
                          });
                        },
                        child: Text("Display this spool"),
                        style: ElevatedButton.styleFrom(
                            textStyle: TextStyle(fontSize: 24)),
                      )),
                  Container(
                    child: Text(
                      "Spools in this document",
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    child: SelectSpool(docNumber: currentDocNumber),
                    height: MediaQuery.of(context).size.height * 0.4,
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.center,
                  ),
                  SizedBox(
                      height: MediaQuery.of(context).size.height * 0.07,
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => SimpleRender(
                                      url: getUrl(
                                          ["${data[0]}", "full", "${data[2]}"]),
                                      urlSpool: widget.url,
                                    )));
                          });
                        },
                        child: Text("Display all spools"),
                        style: ElevatedButton.styleFrom(
                            textStyle: TextStyle(fontSize: 24)),
                      ))
                ],
              ),
            ));
  }
}
