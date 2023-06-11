import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:nautic_viewer/presentation/datascreens/list_spools.dart';
import 'package:nautic_viewer/render_view/main_viewer.dart';
import 'package:nautic_viewer/render_view/simple_viewer.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../connection/if_not_connection.dart';
import '../../data/api/documents_services.dart';
import '../../internal/comp_data/document_info.dart';

class Document extends StatefulWidget {
  Document(
      {Key? key,
      required this.data,
      required this.futureDocs,
      required this.connectionState})
      : super(key: key);

  List data;
  List<DocData> futureDocs;
  String connectionState;

  @override
  State<Document> createState() => _DocumentState();
}

class _DocumentState extends State<Document> {
  var currentDocNumber;
  var currentSpool;
  bool isInternetAvailable = true;

  late double width;
  late double height;

  var brightness;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentDocNumber = widget.data[0];
    currentSpool = widget.data[1];
    _setFetchDocument();
  }

  _setFetchDocument() async {
    await fetchDocument(currentDocNumber).then((value) => {
          setState(() {
            widget.connectionState = value.item2;
            value.item1.forEach((element) {
              widget.futureDocs.add(element);
            });
          })
        });
  }

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch

    print("refresh");
    setState(() {});
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _setFetchDocument();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    setState(() {});
    await Future.delayed(Duration(milliseconds: 1000));
    print("loading");
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    brightness = SchedulerBinding.instance.window.platformBrightness;

    return widget.data.isEmpty
        ? Scaffold(
            body: Center(
                child: LoadingAnimationWidget.threeArchedCircle(
                    color: brightness == Brightness.dark
                        ? Color(0xFF67CAD7)
                        : Color(0xFF2C298A),
                    size: MediaQuery.of(context).size.width * 0.2)),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text("Document"),
            ),
            body: SmartRefresher(
              enablePullDown: true,
              header: WaterDropMaterialHeader(),
              onRefresh: _onRefresh,
              onLoading: _onLoading,
              controller: _refreshController,
              child: widget.connectionState == "failed"
                  ? Positioned(
                      child: CheckConnectionPage(
                      page: Container(
                      ),
                    ))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: ScanData(
                              data: widget.data,
                              futureDocs: widget.futureDocs,
                              connectionState: widget.connectionState,
                            )),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.07,
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          ThreeRender(data: widget.data)));
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
                                            data: [
                                              "${widget.data[0]}",
                                              "full",
                                              "${widget.data[2]}"
                                            ],
                                            dataSpool: widget.data,
                                          )));
                                });
                              },
                              child: Text("Display all spools"),
                              style: ElevatedButton.styleFrom(
                                  textStyle: TextStyle(fontSize: 24)),
                            ))
                      ],
                    ),
            ),
          );
  }
}
