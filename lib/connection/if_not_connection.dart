import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'check_connection.dart';

class CheckConnectionPage extends StatefulWidget {
  CheckConnectionPage({Key? key, required this.page}) : super(key: key);

  Widget page;

  @override
  State<CheckConnectionPage> createState() => _CheckConnectionPageState();
}

class _CheckConnectionPageState extends State<CheckConnectionPage> {
  late double width;
  late double height;

  String connectionState = "connect";

  var isLoading = false;
  Timer? timer;
  late Widget currentPage;

  var brightness;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    timer = Timer.periodic(
        Duration(seconds: 1),
        (Timer t) => isInternetConnected().then((value) => setState(() {
              connectionState = value;
              isLoading = true;
            })));
    connectionState = "connect";
    print(connectionState);
  }

  @override
  void dispose() {
    timer?.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    brightness = SchedulerBinding.instance.window.platformBrightness;

    return connectionState == "connect"
        ? widget.page
        : Scaffold(
            body: RefreshIndicator(
            onRefresh: _pullRefresh,
            child: Stack(
              children: [
                ListView.builder(
                    itemCount: 1,
                    itemBuilder: (context, index) {
                      return SafeArea(
                          child: Column(
                        children: <Widget>[
                          Container(
                              padding: EdgeInsets.all(20),
                              width: width * 0.9,
                              height: height * 0.8,
                              decoration: BoxDecoration(
                                  color: brightness == Brightness.dark
                                      ? Colors.white10
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10)),
                              child: isLoading
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        Icon(
                                          Icons.no_cell,
                                          size: width * 0.2,
                                        ),
                                        Text(
                                            "No connection to deepsea.ru server",
                                            style: TextStyle(fontSize: 30),
                                            textAlign: TextAlign.center),
                                        SizedBox(
                                          height: height * 0.02,
                                        ),
                                        Text(
                                            "Check your connection and refresh the page",
                                            style: TextStyle(fontSize: 22),
                                            textAlign: TextAlign.center),
                                        SizedBox(
                                          height: height * 0.02,
                                        ),
                                        SizedBox(
                                            height: height * 0.07,
                                            width: width * 0.7,
                                            child: ElevatedButton(
                                              onPressed: () async {
                                                setState(() {
                                                  isInternetConnected().then(
                                                      (value) =>
                                                          connectionState =
                                                              value);
                                                });
                                              },
                                              child: Text("Refresh page"),
                                              style: ElevatedButton.styleFrom(
                                                  textStyle:
                                                      TextStyle(fontSize: 20)),
                                            )),
                                      ],
                                    )
                                  : Container(
                                      width: width,
                                      height: height,
                                      child: LoadingAnimationWidget
                                          .threeArchedCircle(
                                              color: Color.fromARGB(
                                                  255, 119, 134, 233),
                                              size: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.2),
                                    )),
                        ],
                      ));
                    })
              ],
            ),
          ));
  }

  Future<void> _pullRefresh() async {
    print("refresh");
    await Future.delayed(const Duration(seconds: 3));
    // why use freshNumbers var? https://stackoverflow.com/a/52992836/2301224
  }
}
