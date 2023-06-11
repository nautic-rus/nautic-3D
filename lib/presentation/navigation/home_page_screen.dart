import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:nautic_viewer/render_view/main_viewer.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../data/api/documents_services.dart';
import '../../data/api/issues_services.dart';
import '../../data/api/zipobject_services.dart';
import '../../internal/comp_data/document_info.dart';
import '../../internal/localfiles/local_files.dart';
import '../appbar/custom_search.dart';
import '../datascreens/data_from_scanner.dart';

class Home extends StatefulWidget {
  Home({
    Key? key,
    required this.futureDocs,
    required this.connectionState,
    required this.futureIssues,
  }) : super(key: key);

  List<DocData> futureDocs;
  String connectionState;
  List<IssuesData> futureIssues;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<dynamic> urlFuture = getLastScanUrl();

  String url = "";

  late double width;
  late double height;
  late double unitHeightValue;
  late double multiplier;
  late List data = [];

  List<String> allDocuments = List<String>.empty(growable: true);
  List<String> documents = List<String>.empty(growable: true);

  double appBarHeight = 50.0;

  var brightness;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getUrl();

    _parseDocuments();
  }

  _parseDocuments() {
    for (int i = 0; i < widget.futureIssues.length; i++) {
      allDocuments.add(widget.futureIssues[i].doc_number);
    }

    allDocuments.toSet().forEach((element) {
      documents.add(element);
    });

    documents.sort();
  }

  _getUrl() async {
    await urlFuture.then((value) => setState(() {
          url = value;
        }));

    data = getData(url);
  }

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    print("refresh");
    // await urlFuture.then((value) => setState(() {
    //   url = value;
    // }));
    print("loading");
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    brightness = SchedulerBinding.instance.window.platformBrightness;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: AppBar(
          title: Container(
              width: width * 0.25,
              height: appBarHeight * 0.9,
              alignment: Alignment.center,
              child: brightness == Brightness.dark
                  ? SvgPicture.asset("assets/NAUTIC_RUS_White_logo.svg")
                  : SvgPicture.asset("assets/nautic_blue.svg")),
          actions: <Widget>[
            Container(
              width: appBarHeight,
              height: appBarHeight * 0.9,
              child: IconButton(
                onPressed: () {
                  showSearch(
                      context: context,
                      delegate: CustomSearchDelegate(
                          data: data,
                          futureDocs: widget.futureDocs,
                          connectionState: widget.connectionState,
                          documents: documents));
                },
                icon: Icon(
                  Icons.search,
                  size: height * 0.04,
                ),
              ),
            )
          ],
        ),
      ),
      body: SmartRefresher(
        enablePullDown: true,
        header: WaterDropMaterialHeader(),
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        controller: _refreshController,
        child: Container(
          color: brightness == Brightness.dark
              ? Colors.white10
              : Colors.grey.shade100,
          child: Container(
            padding: EdgeInsets.all(20),
            alignment: Alignment.center,
            child: data.isEmpty
                ? isLoading()
                : !validateData(data)
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                            AutoSizeText("Last view information",
                                style: TextStyle(fontSize: 30),
                                maxLines: 1,
                                textAlign: TextAlign.center),
                            SizedBox(
                              height: height * 0.02,
                            ),
                            Icon(
                              Icons.find_replace,
                              size: height * 0.2,
                            ),
                            SizedBox(
                              height: height * 0.02,
                            ),
                            AutoSizeText(
                              "Information not found, use QR scanner",
                              style: TextStyle(fontSize: 30),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                            ),
                          ])
                    : Column(
                        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          AutoSizeText(
                            "Last scan information",
                            style: TextStyle(fontSize: 30),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                          ),
                          SizedBox(
                            height: height * 0.1,
                          ),
                          AutoSizeText("SFI-drawing no.:\n${data[0]}",
                              style: TextStyle(fontSize: 25),
                              maxLines: 2,
                              textAlign: TextAlign.center),
                          SizedBox(
                            height: height * 0.05,
                          ),
                          AutoSizeText("Spool: ${data[1]}",
                              style: TextStyle(fontSize: 25),
                              maxLines: 1,
                              textAlign: TextAlign.center),
                          SizedBox(
                            height: height * 0.3,
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
                                                ThreeRender(data: data)));
                                  });
                                },
                                child: AutoSizeText(
                                  "Display this spool",
                                  style: TextStyle(fontSize: 20),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                ),
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
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (context) => Document(
                                                  data: data,
                                                  futureDocs: widget.futureDocs,
                                                  connectionState:
                                                      widget.connectionState,
                                                )));
                                  });
                                },
                                child: AutoSizeText(
                                  "Document information",
                                  style: TextStyle(fontSize: 20),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                ),
                                style: ElevatedButton.styleFrom(
                                    textStyle: TextStyle(fontSize: 20)),
                              )),
                        ],
                      ),
          ),
        ),
      ),
    );
  }

  Future<void> _pullRefresh() async {
    print("refresh");
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) => super.widget));
    await Future.delayed(const Duration(seconds: 3));
    // why use freshNumbers var? https://stackoverflow.com/a/52992836/2301224
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
