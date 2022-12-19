import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nautic_viewer/render_view/main_viewer.dart';

import '../../data/api/department_services.dart';
import '../../data/api/zipobject_services.dart';
import '../../data/parse/parse_spool.dart';

class SelectModel extends StatefulWidget {
  const SelectModel({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SelectModel();
}

class _SelectModel extends State<StatefulWidget> {
  int _index = 0;

  StepperType stepperType = StepperType.horizontal;

  late List<String> drawings;

  List<String> projects = List<String>.empty(growable: true);
  List<String> groups = List<String>.empty(growable: true);
  List<String> numbers = List<String>.empty(growable: true);
  List<String> spoolsList = List<String>.empty(growable: true);
  List<String> department = List<String>.empty(growable: true);

  String selectedProject = "";
  String selectedGroup = "";
  String selectedNumber = "";
  String selectedDepartment = "";

  var data;
  var currentSpool;
  var currentDocNumber;

  void refresh() {}

  void selectProject(String input) {
    setState(() {
      selectedProject = input;
      RegExp search = RegExp('^' + selectedProject);
      RegExp groupMatch = RegExp('(?<=^\\d{6}-)\\d{3}');
      groups.clear();
      drawings
          .where((element) => search.hasMatch(element))
          .toList()
          .forEach((element) {
        RegExpMatch? groupValue = groupMatch.firstMatch(element);
        if (groupValue != null && !groups.contains(groupValue[0])) {
          groups.add(groupValue[0].toString());
        }
      });
      groups.sort();
      _index += 1;
    });
  }

  void selectGroup(String input) {
    setState(() {
      selectedGroup = input;
      RegExp search = RegExp('^' + selectedProject + '-' + selectedGroup);
      RegExp numberMatch = RegExp('(?<=^\\d{6}-\\d{3}-).+');
      numbers.clear();
      drawings
          .where((element) => search.hasMatch(element))
          .toList()
          .forEach((element) {
        RegExpMatch? numberValue = numberMatch.firstMatch(element);
        if (numberValue != null && !numbers.contains(numberValue[0])) {
          numbers.add(numberValue[0].toString());
        }
      });
      numbers.sort();
      _index += 1;
    });
  }

  Future<List<String>> fetchDrawings() async {
    final response =
        await http.get(Uri.parse('https://deep-sea.ru/rest/mobileDrawings'));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return (jsonDecode(response.body) as List<dynamic>).cast<String>();
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load drawings');
    }
  }

  @override
  void initState() {
    super.initState();
    RegExp projectExtract = RegExp("^\\d{6}");
    fetchDrawings().then((value) => {
          setState(() {
            drawings = value;
            drawings.forEach((element) {
              RegExpMatch? match = projectExtract.firstMatch(element);
              if (match != null && !projects.contains(match[0])) {
                projects.add(match[0]!);
              }
            });
          })
        });

    currentDocNumber = "210101-819-0001";
    data = getData("");
    data[0] = currentDocNumber;
    parseSpool(currentDocNumber).then((value) => {
          setState(() {
            value.item1.forEach((element) {
              spoolsList.add(element);
            });
          })
        });

    fetchDepartment().then((value) => {
          setState(() {
            value.forEach((element) {
              department.add(element);
            });
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    content: (projects.isEmpty || spoolsList.isEmpty)
                        ? const CircularProgressIndicator()
                        : Column(children: <Widget>[
                            Container(
                              child: Text("Выбор проекта",
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
                        child: Text("Выбор отдела",
                            style:
                                TextStyle(fontSize: 24, color: Colors.black)),
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
                              onTap: () => {selectProject(projects[index])},
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(40)),
                                child: Text(department[index],
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
                        child: Text("Выбор чертежа",
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
                          itemCount: groups.length,
                          itemBuilder: (BuildContext ctx, index) {
                            return GestureDetector(
                              onTap: () => {selectGroup(groups[index])},
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(40)),
                                child: Text(groups[index],
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
                        child: Text("Выбор модели",
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
                                  data[1] = spoolsList[_index];
                                  var url = getUrl(data);
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(
                                          builder: (context) =>
                                              ThreeRender(data: [])))
                                      .then((value) => _index = _index);
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
