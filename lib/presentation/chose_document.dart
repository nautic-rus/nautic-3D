import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nautic_viewer/presentation/render.dart';

import '../data/api/issues_services.dart';
import '../data/api/zipobject_services.dart';
import '../data/parse/parse_spool.dart';

class SelectModel extends StatefulWidget {
  const SelectModel({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SelectModel();
}

class _SelectModel extends State<StatefulWidget> {
  int _index = 0;

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

  var data;
  var currentSpool;
  var currentDocNumber;

  void refresh() {}

  void selectProject(String input) {
    setState(() {
      selectedProject = input;
      departments = [];
      for (int i = 0; i < futureIssues.length; i++) {
        if (futureIssues[i].project == selectedProject) {
          allDepartments.add(futureIssues[i].department);
        }
      }
      allDepartments.toSet().forEach((element) {
        departments.add(element);
      });
      _index += 1;
    });
  }

  void selectDepartment(String input) {
    setState(() {
      selectedDepartment = input;
      documents = [];
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
      _index += 1;
    });
  }

  void selectDocument(String input) {
    setState(() {
      selectedDocument = input;
      spoolsList = [];
      parseSpool(selectedDocument).then((value) => {
        setState(() {
          value.forEach((element) {
            spoolsList.add(element);
          });
        })
      });
      _index += 1;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchIssues().then((value) {
      setState(() {
        value.forEach((element) {
          futureIssues.add(element);
        });
      });
      for (int i = 0; i < futureIssues.length; i++) {
        if (futureIssues[i].department == "System" &&
            futureIssues[i].issue_type == "RKD") {
          allProjects.add(futureIssues[i].project);
        }
      }
      allProjects.toSet().forEach((element) {
        projects.add(element);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: Stepper(
                currentStep: _index,
                type: stepperType,
                physics: ScrollPhysics(),
                controlsBuilder: (context, _) => Container(),
                onStepTapped: (step) => tapped(step),
                onStepContinue: continued,
                onStepCancel: cancel,
                steps: <Step>[
                  Step(
                    title: const Icon(Icons.directions_boat_outlined,
                        color: Colors.black),
                    content: (projects.isEmpty)
                        ? const CircularProgressIndicator()
                        : Column(children: <Widget>[
                            Container(
                              child: Text("PROJECT",
                                  style: TextStyle(
                                      fontSize: 24, color: Colors.black)),
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
                                          color: Colors.grey.shade100,
                                          borderRadius:
                                              BorderRadius.circular(40)),
                                      child: Text(projects[index],
                                          style: TextStyle(
                                              fontSize: 24,
                                              color: Colors.black)),
                                    ),
                                  );
                                }),
                          ]),
                    isActive: _index >= 0,
                    state:
                        _index >= 1 ? StepState.complete : StepState.disabled,
                  ),
                  Step(
                    title: const Icon(Icons.directions_boat_outlined,
                        color: Colors.black),
                    content: Column(children: <Widget>[
                      Container(
                        child: Text("DEPARTMENT",
                            style:
                                TextStyle(fontSize: 24, color: Colors.black)),
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
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(40)),
                                child: Text(departments[index],
                                    style: TextStyle(
                                        fontSize: 24, color: Colors.black)),
                              ),
                            );
                          }),
                    ]),
                    isActive: _index >= 1,
                    state:
                        _index >= 2 ? StepState.complete : StepState.disabled,
                  ),
                  Step(
                    title: const Icon(Icons.file_copy_outlined,
                        color: Colors.black),
                    content: Column(children: <Widget>[
                      Container(
                        child: Text("DOCUMENT",
                            style:
                                TextStyle(fontSize: 24, color: Colors.black)),
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
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(40)),
                                child: Text(documents[index],
                                    style: TextStyle(
                                        fontSize: 24, color: Colors.black)),
                              ),
                            );
                          }),
                    ]),
                    isActive: _index >= 2,
                    state:
                        _index >= 3 ? StepState.complete : StepState.disabled,
                  ),
                  Step(
                    title: const Icon(Icons.draw_outlined, color: Colors.black),
                    content: Column(children: <Widget>[
                      Container(
                        child: Text("SPOOL",
                            style:
                                TextStyle(fontSize: 24, color: Colors.black)),
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
                              onTap: () => {
                                setState(() {
                                  var url = getUrl(["$selectedProject", "${spoolsList[index]}"]);
                                  Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ThreeRender(url: url))).then((value) => _index = _index);
                                })
                              },
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(40)),
                                child: Text(spoolsList[index],
                                    style: TextStyle(
                                        fontSize: 24, color: Colors.black)),
                              ),
                            );
                          }),
                    ]),
                    isActive: _index == 3,
                    state:
                        _index == 4 ? StepState.complete : StepState.disabled,
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
    );
  }

  switchStepsType() {
    setState(() => stepperType == StepperType.vertical
        ? stepperType = StepperType.horizontal
        : stepperType = StepperType.vertical);
  }

  tapped(int step) {
    setState(() => _index = step);
  }

  continued() {
    _index < 3 ? setState(() => _index += 1) : null;
  }

  cancel() {
    _index > 0 ? setState(() => _index -= 1) : null;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}
