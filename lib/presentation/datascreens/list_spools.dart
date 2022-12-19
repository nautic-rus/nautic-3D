import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:nautic_viewer/render_view/main_viewer.dart';

import '../../data/api/zipobject_services.dart';
import '../../data/parse/parse_spool.dart';

class SelectSpool extends StatefulWidget {
  SelectSpool(
      {Key? key, required this.docNumber})
      : super(key: key);

  String docNumber;

  @override
  State<SelectSpool> createState() => _SelectSpool();
}

class _SelectSpool extends State<SelectSpool> {
  int _index = 0;

  List<String> spoolsList = List<String>.empty(growable: true);

  var data;

  var brightness;

  String connectionState = "connect";

  void refresh() {}

  @override
  void initState() {
    super.initState();
    data = getData("");
    data[0] = widget.docNumber;
    parseSpool(widget.docNumber).then((value) => {
          setState(() {
            connectionState = value.item2;
            value.item1.forEach((element) {
              spoolsList.add(element);
            });
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    brightness = SchedulerBinding.instance.window.platformBrightness;
    return connectionState == "connect"
        ? spoolsList.isEmpty
            ? isLoading()
            : Container(
                child: GridView.builder(
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
                            _index = index;
                            data[1] = spoolsList[_index];
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ThreeRender(data: data)));
                          })
                        },
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: brightness == Brightness.dark
                                  ? Colors.white10
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(40)),
                          child: Text(spoolsList[index],
                              style: TextStyle(fontSize: 20)),
                        ),
                      );
                    }),
              )
        : connectionState == "empty"
            ? const Center(
                child: AutoSizeText(
                    "There is no data on the server for this query",
                    style: TextStyle(fontSize: 22, color: Colors.red),
                    maxLines: 3,
                    textAlign: TextAlign.center),
              )
            : Center(
                child: AutoSizeText(
                    "No connection to the server, maybe it is broken",
                    style: TextStyle(fontSize: 22, color: Colors.red),
                    maxLines: 3,
                    textAlign: TextAlign.center),
              );
  }

  Widget isLoading() {
    return Center(
        child: LoadingAnimationWidget.threeArchedCircle(
            color: brightness == Brightness.dark
                ? Color(0xFF67CAD7)
                : Color(0xFF2C298A),
            size: MediaQuery.of(context).size.width * 0.2));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}
