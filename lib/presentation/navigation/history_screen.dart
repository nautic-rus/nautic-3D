import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:nautic_viewer/render_view/main_viewer.dart';

import '../../data/api/zipobject_services.dart';
import '../../data/parse/parse_spool.dart';
import '../datascreens/data_from_scanner.dart';

class History extends StatefulWidget {
  History({Key? key, required this.docNumber}) : super(key: key);

  String docNumber;

  @override
  State<History> createState() => _History();
}

class _History extends State<History> {
  int _index = 0;

  List<String> spoolsList = List<String>.empty(growable: true);
  List<String> documentsList = List<String>.empty(growable: true);

  var data;
  var currentDocNumber;

  void refresh() {}

  @override
  void initState() {
    super.initState();
    currentDocNumber = widget.docNumber;
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
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0),
        child: AppBar(
          backgroundColor: Colors.white,
        ),
      ),
      body: spoolsList.isEmpty
          ? Scaffold(
              body: Center(
                  child: LoadingAnimationWidget.threeArchedCircle(
                      color: Color.fromARGB(255, 119, 134, 233),
                      size: MediaQuery.of(context).size.width * 0.2)),
            )
          : Container(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: GridView.builder(
                  physics: ScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 400,
                      childAspectRatio: 3 / 1,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20),
                  itemCount: spoolsList.length,
                  itemBuilder: (BuildContext ctx, index) {
                    return GestureDetector(
                      onTap: () => {
                        setState(() {
                          _index = index;
                          data[1] = spoolsList[_index];
                          var url = getUrl(data);
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => Document(data: [], futureDocs: [], connectionState: "",)));
                        })
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(40)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Text("Document:\n $currentDocNumber",
                                    style: TextStyle(fontSize: 18),
                                    textAlign: TextAlign.center),
                                Text("Spool:\n ${spoolsList[index]}",
                                    style: TextStyle(fontSize: 18),
                                    textAlign: TextAlign.center)
                              ],
                            ),
                            Image.asset(
                              "assets/qr.png",
                              width: MediaQuery.of(context).size.width * 0.2,
                              height: MediaQuery.of(context).size.width * 0.2,
                            )
                          ],
                        ),
                      ),
                    );
                  }),
            ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}
