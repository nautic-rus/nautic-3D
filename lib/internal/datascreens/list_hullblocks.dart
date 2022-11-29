import 'package:flutter/material.dart';

import '../../data/api/hullblocks_services.dart';

class HullBlocks extends StatefulWidget {
  const HullBlocks({Key? key}) : super(key: key);

  @override
  State<HullBlocks> createState() => _HullBlocksState();
}

class _HullBlocksState extends State<HullBlocks> {
  List<Code> futureCode = List<Code>.empty(growable: true);

  int selectedIndex = -1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchCode().then((value) => {
          setState(() {
            value.forEach((element) {
              futureCode.add(element);
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
            : "OID: ${futureCode[selectedIndex].oid}\n"
                "CODE: ${futureCode[selectedIndex].code}\n"
                "DESCRIPTION: ${futureCode[selectedIndex].description}\n"),
        Expanded(
            child: ListView.builder(
          itemBuilder: _createListView,
          itemCount: futureCode.length,
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
        child: Text(futureCode[index].code, style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
