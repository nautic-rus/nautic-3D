import 'package:flutter/material.dart';

import '../data/api/project_services.dart';

class ListElements extends StatefulWidget {
  const ListElements({Key? key}) : super(key: key);

  @override
  State<ListElements> createState() => _ListElementsState();
}

class _ListElementsState extends State<ListElements> {
  List<ProjectName> futureProjectName = List<ProjectName>.empty(growable: true);

  int selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    fetchProjects().then((value) => {
          setState(() {
            value.forEach((element) {
              futureProjectName.add(element);
            });
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(selectedIndex == -1
            ? "NO"
            : "id: ${futureProjectName[selectedIndex].id}\n"
                "rkd: ${futureProjectName[selectedIndex].rkd}\n"
                "pdsp: ${futureProjectName[selectedIndex].pdsp}\n"
                "foran: ${futureProjectName[selectedIndex].foran}\n"
                "cloud: ${futureProjectName[selectedIndex].cloud}\n"
                "cloudRkd: ${futureProjectName[selectedIndex].cloudRkd}\n"),
        Expanded(
            child: ListView.builder(
          itemBuilder: _createListView,
          itemCount: futureProjectName.length,
        ))
      ],
    );
  }

  Widget _createListView(BuildContext context, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        padding: EdgeInsets.symmetric(vertical: 8),
        color: index == selectedIndex ? Colors.black12 : Colors.white60,
        child: Text(futureProjectName[index].foran,
            style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
