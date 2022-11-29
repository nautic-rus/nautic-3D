import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:nautic_viewer/render_view/main_viewer.dart';

import '../../data/api/issues_services.dart';
import '../../data/api/zipobject_services.dart';
import '../../data/parse/parse_spool.dart';

class SelectModel extends StatefulWidget {
  const SelectModel({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SelectModel();
}

class _SelectModel extends State<StatefulWidget> {
  int _pageindex = 0;
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

  List<IssuesData> futureIssues = List<IssuesData>.empty(growable: true);

  String selectedProject = "";
  String selectedDepartment = "";
  String selectedDocument = "";

  late double width;
  late double height;

  var isConnected = true;

  var brightness;

  var data;

  void refresh() {}

  void selectProject(String input) {
    setState(() {
      selectedProject = input;
      departments.clear();
      allDepartments.clear();
      for (int i = 0; i < futureIssues.length; i++) {
        if (futureIssues[i].department == "System" &&
            futureIssues[i].project == selectedProject) {
          allDepartments.add(futureIssues[i].department);
        }
      }
      allDepartments.toSet().forEach((element) {
        departments.add(element);
      });
      departments.sort();
      indexes.add(_pageindex);
      _pageindex += 1;
    });
  }

  void selectDepartment(String input) {
    setState(() {
      selectedDepartment = input;
      documents.clear();
      allDocuments.clear();
      for (int i = 0; i < futureIssues.length; i++) {
        if (futureIssues[i].department == selectedDepartment &&
            futureIssues[i].issue_type == "RKD" &&
            futureIssues[i].project == selectedProject) {
          allDocuments.add(futureIssues[i].doc_number);
        }
      }
      allDocuments.toSet().forEach((element) {
        documents.add(element);
      });
      documents.sort();
      indexes.add(_pageindex);
      _pageindex += 1;
    });
  }

  void selectDocument(String input) {
    setState(() {
      selectedDocument = input;
      data[0] = selectedDocument;
      spoolsList.clear();
      parseSpool(selectedDocument).then((value) =>
      {
        setState(() {
          isConnected = value.item2;
          value.item1.forEach((element) {
            spoolsList.add(element);
          });
        })
      });
      indexes.add(_pageindex);
      _pageindex += 1;
    });
  }

  @override
  void initState() {
    super.initState();
    data = getData("");
    fetchIssues().then((value) {
      setState(() {
        isConnected = value.item2;
        value.item1.forEach((element) {
          futureIssues.add(element);
        });
      });
      setState(() {
        for (int i = 0; i < futureIssues.length; i++) {
          if (futureIssues[i].department == "System" &&
              futureIssues[i].issue_type == "RKD" &&
              (futureIssues[i].project == "NR004" ||
                  futureIssues[i].project == "170701")) {
            allProjects.add(futureIssues[i].project);
          }
        }
        allProjects.toSet().forEach((element) {
          projects.add(element);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    brightness = SchedulerBinding.instance.window.platformBrightness;
    return WillPopScope(child: Scaffold(
      appBar: AppBar(
        title: Container(
            width: width,
            height: height * 0.05,
            alignment: Alignment.center,
            child: brightness == Brightness.dark
                ? SvgPicture.asset("assets/NAUTIC_RUS_White_logo.svg")
                : SvgPicture.asset("assets/nautic_blue.svg")),
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: Stepper(
                currentStep: _pageindex,
                type: stepperType,
                physics: ScrollPhysics(),
                controlsBuilder: (context, _) => Container(),
                onStepTapped: (step) => tapped(step),
                onStepContinue: continued,
                onStepCancel: cancel,
                steps: <Step>[
                  Step(
                    title: const Icon(Icons.directions_boat_outlined),
                    content: isConnected
                        ? projects.isEmpty
                        ? isLoading()
                        : Column(children: <Widget>[
                      Container(
                        child: Text("PROJECTS",
                            style: TextStyle(
                                fontSize: 24)),
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
                          itemBuilder: (BuildContext ctx, index) {
                            return GestureDetector(
                              onTap: () =>
                              {selectProject(projects[index])},
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: brightness == Brightness.dark
                                        ? Colors.white10
                                        : Colors.grey.shade100,
                                    borderRadius:
                                    BorderRadius.circular(40)),
                                child: Text(projects[index],
                                    style: TextStyle(
                                        fontSize: 24)),
                              ),
                            );
                          }),
                    ])
                        : const Center(
                      child: AutoSizeText(
                          "There is no connection to the deep-sea.ru server. Please try again later",
                          style:
                          TextStyle(fontSize: 22, color: Colors.red),
                          maxLines: 3,
                          textAlign: TextAlign.center),
                    ),
                    isActive: _pageindex >= 0,
                    state: _pageindex >= 1
                        ? StepState.complete
                        : StepState.disabled,
                  ),
                  Step(
                    title: const Icon(Icons.workspaces_outline),
                    content: Column(children: <Widget>[
                      Container(
                        child: Text("DEPARTMENTS",
                            style:
                            TextStyle(fontSize: 24)),
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
                              onTap: () =>
                              {selectDepartment(departments[index])},
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: brightness == Brightness.dark
                                        ? Colors.white10
                                        : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(40)),
                                child: Text(departments[index],
                                    style: TextStyle(
                                        fontSize: 24)),
                              ),
                            );
                          }),
                    ]),
                    isActive: _pageindex >= 1,
                    state: _pageindex >= 2
                        ? StepState.complete
                        : StepState.disabled,
                  ),
                  Step(
                    title: const Icon(Icons.file_copy_outlined),
                    content: Column(children: <Widget>[
                      Container(
                        child: Text("DOCUMENTS",
                            style:
                            TextStyle(fontSize: 24)),
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
                              onTap: () => {selectDocument(documents[index])},
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: brightness == Brightness.dark
                                        ? Colors.white10
                                        : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(40)),
                                child: Text(documents[index],
                                    style: TextStyle(
                                        fontSize: 24)),
                              ),
                            );
                          }),
                    ]),
                    isActive: _pageindex >= 2,
                    state: _pageindex >= 3
                        ? StepState.complete
                        : StepState.disabled,
                  ),
                  Step(
                    title: const Icon(Icons.draw_outlined),
                    content: isConnected
                        ? spoolsList.isEmpty
                        ? isLoading()
                        : Column(children: <Widget>[
                      Container(
                        child: Text("SPOOLS",
                            style: TextStyle(
                                fontSize: 24)),
                        padding: EdgeInsets.only(bottom: 20),
                      ),
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
                          itemBuilder: (BuildContext ctx, index) {
                            return GestureDetector(
                              onTap: () =>
                              {
                                setState(() {
                                  data[1] = spoolsList[index];
                                  var url = getUrl(data);
                                  print(url);
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(
                                      builder: (context) =>
                                          ThreeRender(url: url)))
                                      .then((value) =>
                                  _pageindex = _pageindex);
                                })
                              },
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: brightness == Brightness.dark
                                        ? Colors.white10
                                        : Colors.grey.shade100,
                                    borderRadius:
                                    BorderRadius.circular(40)),
                                child: Text(spoolsList[index],
                                    style: TextStyle(
                                        fontSize: 24)),
                              ),
                            );
                          }),
                    ])
                        : const Center(
                      child: AutoSizeText(
                          "There is no connection to the deep-sea.ru server. Please try again later",
                          style:
                          TextStyle(fontSize: 22, color: Colors.red),
                          maxLines: 3,
                          textAlign: TextAlign.center),
                    ),
                    isActive: _pageindex == 3,
                    state: _pageindex == 4
                        ? StepState.complete
                        : StepState.disabled,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.list),
        onPressed: switchStepsType,
      ),
    ),         onWillPop: () async {
      setState(() {
        if (indexes.length > 0) {
          setState(() {
            _pageindex = indexes[indexes.length - 1];
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
    setState(() =>
    stepperType == StepperType.vertical
        ? stepperType = StepperType.horizontal
        : stepperType = StepperType.vertical);
  }

  tapped(int step) {
    setState(() => _pageindex = step);
  }

  continued() {
    _pageindex < 3 ? setState(() => _pageindex += 1) : null;
  }

  cancel() {
    _pageindex > 0 ? setState(() => _pageindex -= 1) : null;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Widget isLoading() {
    return Center(
        child: LoadingAnimationWidget.threeArchedCircle(
            color: brightness == Brightness.dark ? Color(0xFF67CAD7) : Color(0xFF2C298A),
            size: MediaQuery
                .of(context)
                .size
                .width * 0.2));
  }
}
