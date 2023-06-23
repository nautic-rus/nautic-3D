import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:nautic_viewer/render_view/main_viewer.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../data/api/issues_services.dart';
import '../../data/api/zipobject_services.dart';
import '../../data/parse/parse_spool.dart';
import '../../render_view/simple_viewer.dart';

class SelectModel extends StatefulWidget {
  SelectModel({
    Key? key,
    required this.futureIssues,
    required this.connectionState
  }) : super(key: key);

  List<IssuesData> futureIssues;
  String connectionState;
  @override
  State<StatefulWidget> createState() => _SelectModelState();
}

class _SelectModelState extends State<SelectModel> {
  int _selectedIndex = 0;
  List indexes = [];

  StepperType stepperType = StepperType.horizontal;

  late List<String> drawings;

  List<String> allProjects = List<String>.empty(growable: true);
  List<String> allSpoolsList = List<String>.empty(growable: true);
  List<String> allDocuments = List<String>.empty(growable: true);
  List<String> allDepartments = List<String>.empty(growable: true);

  List<String> projects = List<String>.empty(growable: true);
  List<String> spoolsList = List<String>.empty(growable: true);
  List<String> documents = List<String>.empty(growable: true);
  List<String> departments = List<String>.empty(growable: true);

  String selectedProject = "";
  String selectedDepartment = "";
  String selectedDocument = "";

  late double width;
  late double height;

  double appBarHeight = 50.0;


  String loadSpools = "connect";

  var brightness;

  var data;

  void refresh() {}

  void selectProject(String input) {
    setState(() {
      selectedProject = input;
      departments.clear();
      allDepartments.clear();
      for (int i = 0; i < widget.futureIssues.length; i++) {
        if (widget.futureIssues[i].department == "System" &&
            widget.futureIssues[i].project == selectedProject) {
          allDepartments.add(widget.futureIssues[i].department);
        }
      }
      allDepartments.toSet().forEach((element) {
        departments.add(element);
      });
      departments.sort();
      indexes.add(_selectedIndex);
      print(indexes);
      _selectedIndex++;
    });
  }

  void selectDepartment(String input) {
    setState(() {
      selectedDepartment = input;
      documents.clear();
      allDocuments.clear();
      for (int i = 0; i < widget.futureIssues.length; i++) {
        if (widget.futureIssues[i].department == selectedDepartment &&
            widget.futureIssues[i].issue_type == "RKD" &&
            widget.futureIssues[i].project == selectedProject) {
          allDocuments.add(widget.futureIssues[i].doc_number);
        }
      }
      allDocuments.toSet().forEach((element) {
        documents.add(element);
      });
      documents.sort();
      _selectedIndex++;
    });
  }

  void selectDocument(String input) {
    setState(() {
      selectedDocument = input;
      data[0] = selectedDocument;
      spoolsList.clear();
      parseSpool(selectedDocument).then((value) => {
            setState(() {
              loadSpools = value.item2;
              value.item1.forEach((element) {
                spoolsList.add(element);
              });
            })
          });
      _selectedIndex++;
    });
  }

  @override
  void initState() {
    super.initState();
    data = getData("");
    for (int i = 0; i < widget.futureIssues.length; i++) {
      if (widget.futureIssues[i].department == "System" &&
          widget.futureIssues[i].issue_type == "RKD" &&
          (widget.futureIssues[i].project == "NR004" ||
              widget.futureIssues[i].project == "170701")) {
        allProjects.add(widget.futureIssues[i].project);
      }
    }
    allProjects.toSet().forEach((element) {
      projects.add(element);
    });
  }

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    setState(() {});
    print("refresh");
    await _setFetchIssues().timeout(const Duration(seconds: 10));
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    setState(() {});
    print("loading");
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  _setFetchIssues() async {
    await fetchIssues().then((value) {
      setState(() {
        widget.connectionState = value.item2;
        widget.futureIssues = [];
        loadSpools = value.item2;
        value.item1.forEach((element) {
          widget.futureIssues.add(element);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    brightness = SchedulerBinding.instance.window.platformBrightness;
    return WillPopScope(
        child: Scaffold(
            appBar: AppBar(
              title: Container(
                  width: 100,
                  height: appBarHeight * 0.9,
                  child: brightness == Brightness.dark
                      ? SvgPicture.asset("assets/NAUTIC_RUS_White_logo.svg")
                      : SvgPicture.asset("assets/nautic_blue.svg")),
            ),
            body: SmartRefresher(
              enablePullDown: true,
              header: WaterDropMaterialHeader(),
              onRefresh: _onRefresh,
              onLoading: _onLoading,
              controller: _refreshController,
              child: Container(
                child: Stepper(
                  currentStep: _selectedIndex,
                  type: stepperType,
                  physics: ScrollPhysics(),
                  controlsBuilder: (context, _) => Container(),
                  onStepTapped: (step) => tapped(step),
                  onStepContinue: continued,
                  onStepCancel: cancel,
                  steps: <Step>[
                    Step(
                      title: Icon(Icons.directions_boat_outlined, size: height * 0.03),
                      content: widget.connectionState == "connect"
                          ? projects.isEmpty
                          ? isLoading()
                          : Column(children: <Widget>[
                        Container(
                          child: Text("PROJECTS",
                              style: TextStyle(fontSize: 24)),
                          padding: EdgeInsets.only(bottom: 20),
                        ),
                        GridView.builder(
                            physics: ScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: projects.length,
                            gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 200,
                                childAspectRatio: 3 / 1,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 20),
                            itemBuilder:
                                (BuildContext ctx, index) {
                              return GestureDetector(
                                onTap: () => {
                                  selectProject(projects[index])
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: brightness ==
                                          Brightness.dark
                                          ? Colors.white10
                                          : Colors
                                          .grey.shade100,
                                      borderRadius:
                                      BorderRadius.circular(
                                          40)),
                                  child: Text(projects[index],
                                      style: TextStyle(
                                          fontSize: 24)),
                                ),
                              );
                            }),
                      ])
                          : widget.connectionState == "empty"
                          ? const Center(
                        child: AutoSizeText(
                            "There is no data on the server, something wrong",
                            style: TextStyle(
                                fontSize: 22,
                                color: Colors.redAccent),
                            maxLines: 3,
                            textAlign: TextAlign.center),
                      )
                          : const Center(
                        child: AutoSizeText(
                            "No connection to the server, maybe it is broken",
                            style: TextStyle(
                                fontSize: 22,
                                color: Colors.redAccent),
                            maxLines: 3,
                            textAlign: TextAlign.center),
                      ),
                      isActive: _selectedIndex >= 0,
                      state: _selectedIndex >= 1
                          ? StepState.complete
                          : StepState.disabled,
                    ),
                    Step(
                      title: Icon(Icons.workspaces_outline, size: height * 0.03),
                      content: Column(children: <Widget>[
                        Container(
                          child: Text("DEPARTMENTS",
                              style: TextStyle(fontSize: 24)),
                          padding: EdgeInsets.only(bottom: 20),
                        ),
                        GridView.builder(
                            physics: ScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: departments.length,
                            gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 330,
                                childAspectRatio: 4 / 1,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 20),
                            itemBuilder: (BuildContext ctx, index) {
                              return GestureDetector(
                                onTap: () => {
                                  selectDepartment(departments[index])
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: brightness == Brightness.dark
                                          ? Colors.white10
                                          : Colors.grey.shade100,
                                      borderRadius:
                                      BorderRadius.circular(40)),
                                  child: Text(departments[index],
                                      style: TextStyle(fontSize: 24)),
                                ),
                              );
                            }),
                      ]),
                      isActive: _selectedIndex >= 1,
                      state: _selectedIndex >= 2
                          ? StepState.complete
                          : StepState.disabled,
                    ),
                    Step(
                      title: Icon(Icons.file_copy_outlined, size: height * 0.03),
                      content: Column(children: <Widget>[
                        Container(
                          child: Text("DOCUMENTS",
                              style: TextStyle(fontSize: 24)),
                          padding: EdgeInsets.only(bottom: 20),
                        ),
                        GridView.builder(
                            physics: ScrollPhysics(),
                            shrinkWrap: true,
                            gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 400,
                                childAspectRatio: 5 / 1,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 20),
                            itemCount: documents.length,
                            itemBuilder: (BuildContext ctx, index) {
                              return GestureDetector(
                                onTap: () =>
                                {selectDocument(documents[index])},
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: brightness == Brightness.dark
                                          ? Colors.white10
                                          : Colors.grey.shade100,
                                      borderRadius:
                                      BorderRadius.circular(40)),
                                  child: Text(documents[index],
                                      style: TextStyle(fontSize: 24)),
                                ),
                              );
                            }),
                      ]),
                      isActive: _selectedIndex >= 2,
                      state: _selectedIndex >= 3
                          ? StepState.complete
                          : StepState.disabled,
                    ),
                    Step(
                      title: Icon(Icons.draw_outlined, size: height * 0.03),
                      content: loadSpools == "connect"
                          ? spoolsList.isEmpty
                          ? isLoading()
                          : Column(children: <Widget>[
                        Container(
                          child: Text("SPOOLS",
                              style: TextStyle(fontSize: 24)),
                          padding: EdgeInsets.only(bottom: 20),
                        ),
                        // SizedBox(
                        //   height: MediaQuery.of(context)
                        //           .size
                        //           .height *
                        //       0.07,
                        //   width: MediaQuery.of(context)
                        //           .size
                        //           .width *
                        //       0.9,
                        //   child: ElevatedButton(
                        //     onPressed: () {
                        //       setState(() {
                        //         Navigator.of(context).push(
                        //             MaterialPageRoute(
                        //                 builder: (context) =>
                        //                     SimpleRender(
                        //                       data: [
                        //                         selectedDocument,
                        //                         "full",
                        //                         "${data[2]}"
                        //                       ],
                        //                       dataSpool: [],
                        //                     )));
                        //       });
                        //     },
                        //     child: Text("Display all spools"),
                        //     style: ElevatedButton.styleFrom(
                        //         textStyle:
                        //             TextStyle(fontSize: 24)),
                        //   ),
                        // ),
                        GridView.builder(
                            physics: ScrollPhysics(),
                            shrinkWrap: true,
                            gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 200,
                                childAspectRatio: 3 / 1,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 20),
                            itemCount: spoolsList.length,
                            itemBuilder:
                                (BuildContext ctx, index) {
                              return GestureDetector(
                                onTap: () => {
                                  setState(() {
                                    data[1] = spoolsList[index];
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                        builder: (context) =>
                                            ThreeRender(
                                                data:
                                                data)))
                                        .then((value) =>
                                    _selectedIndex =
                                        _selectedIndex);
                                  })
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: brightness ==
                                          Brightness.dark
                                          ? Colors.white10
                                          : Colors
                                          .grey.shade100,
                                      borderRadius:
                                      BorderRadius.circular(
                                          40)),
                                  child: Text(spoolsList[index],
                                      style: TextStyle(
                                          fontSize: 24)),
                                ),
                              );
                            }),
                      ])
                          : loadSpools == "empty"
                          ? const Center(
                        child: AutoSizeText(
                            "There is no data on the server for this document",
                            style: TextStyle(fontSize: 22),
                            maxLines: 3,
                            textAlign: TextAlign.center),
                      )
                          : const Center(
                        child: AutoSizeText(
                            "No connection to the server, maybe it is broken",
                            style: TextStyle(
                                fontSize: 22,
                                color: Colors.redAccent),
                            maxLines: 3,
                            textAlign: TextAlign.center),
                      ),
                      isActive: _selectedIndex == 3,
                      state: _selectedIndex == 4
                          ? StepState.complete
                          : StepState.disabled,
                    ),
                  ],
                ),
              ),
            ),
            floatingActionButton: _selectedIndex > 0
                ? FloatingActionButton.extended(
                    label: AutoSizeText("Back",
                        style: TextStyle(fontSize: 18),
                        maxLines: 1,
                        textAlign: TextAlign.center),
                    onPressed: () => setState(() {
                          _selectedIndex--;
                          widget.connectionState = "connect";
                          loadSpools = "connect";
                        }))
                : null),
        onWillPop: () async {
          setState(() {
            if (indexes.length > 0) {
              setState(() {
                _selectedIndex = indexes[indexes.length - 1];
                print(_selectedIndex);
                indexes.removeLast();
              });
            } else {
              SystemChannels.platform.invokeMethod('SystemNavigator.pop');
            }
          });
          return false;
        });
  }

  switchStepsType() {
    setState(() => stepperType == StepperType.vertical
        ? stepperType = StepperType.horizontal
        : stepperType = StepperType.vertical);
  }

  tapped(int step) {
    setState(() {
      _selectedIndex = step;
    });
  }

  continued() {
    _selectedIndex < 3 ? setState(() => _selectedIndex += 1) : null;
  }

  cancel() {
    _selectedIndex > 0 ? setState(() => _selectedIndex -= 1) : null;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
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
