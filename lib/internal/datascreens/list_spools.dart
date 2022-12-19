import 'package:flutter/material.dart';

import '../../data/api/documents_services.dart';
import '../../data/api/zipobject_services.dart';
import '../../data/parse/parse_spool.dart';
import '../../render_view/main_viewer.dart';

class Spools extends StatefulWidget {
  const Spools({Key? key}) : super(key: key);

  @override
  State<Spools> createState() => _SpoolsState();
}

class _SpoolsState extends State<Spools> {
  List<DocData> futureSpool = List<DocData>.empty(growable: true);
  List<String> spoolsList = List<String>.empty(growable: true);
  List<int> spoolsInt = List<int>.empty(growable: true);

  int selectedIndex = -1;
  var data;
  var currentSpool;
  var currentDocNumber;


  @override
  void initState() {
    super.initState();
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
            : "spool: ${spoolsList[selectedIndex]}\n"),
        Expanded(
            child: ListView.builder(
          itemBuilder: _createListView,
          itemCount: spoolsList.length,
        ))
      ],
    );
  }

  Widget _createListView(BuildContext context, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
          data[1] = spoolsList[selectedIndex];
          var url = getUrl(data);
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => ThreeRender(data: [])));
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        padding: EdgeInsets.symmetric(vertical: 8),
        color: index == selectedIndex ? Colors.black12 : Colors.white60,
        child: Text(spoolsList[index], style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
