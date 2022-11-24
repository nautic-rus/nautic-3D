import 'package:flutter/material.dart';
import 'package:nautic_viewer/data/parse/parse_issue.dart';

import '../data/api/spools_services.dart';
import '../data/api/zipobject_services.dart';
import '../data/parse/parse_spool.dart';
import '../presentation/render.dart';

class Documents extends StatefulWidget {
  const Documents({Key? key}) : super(key: key);

  @override
  State<Documents> createState() => _DocumentsState();
}

class _DocumentsState extends State<Documents> {
  List<SpoolData> futureDocument = List<SpoolData>.empty(growable: true);
  List<String> documentsList = List<String>.empty(growable: true);

  int selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    parseIssue("210101-819-0001", "System").then((value) => {
      setState(() {
        value.forEach((element) {
          documentsList.add(element);
        });
      })
    });
  }

  @override
  Widget build(BuildContext context) {
    // int myInt;
    // for (int i = 0; i < futureSpool.length; i++) {
    //   spoolsList.add(futureSpool[i].spool);
    // }
    //
    // spoolsInt = spoolsList.map(int.parse).toSet().toList();
    // spoolsInt.sort();
    // print(spoolsInt.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(selectedIndex == -1
            ? "LOADING"
            : "spool: ${documentsList[selectedIndex]}\n"),
        Expanded(
            child: ListView.builder(
              itemBuilder: _createListView,
              itemCount: documentsList.length,
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
        child: Text(documentsList[index], style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
