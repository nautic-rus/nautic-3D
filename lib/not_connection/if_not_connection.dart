import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../data/api/check_connection.dart';

class NoConnectionPage extends StatefulWidget {
  NoConnectionPage({Key? key, required this.page}) : super(key: key);

  Widget page;

  @override
  State<NoConnectionPage> createState() => _NoConnectionPageState();
}

class _NoConnectionPageState extends State<NoConnectionPage> {
  late double width;
  late double height;
  var status = false;
  var isLoading = false;
  Timer? timer;
  late Widget currentPage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    timer = Timer.periodic(
        Duration(seconds: 1),
        (Timer t) => isInternetConnected()
            .then((value) => setState(() {
          status = value;
          isLoading = true;
        })));
    status = true;
    print(status);
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
    height = height - height * 0.1;

    return status
        ? widget.page
        : Scaffold(
            body: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/gradik_iz_ser.png"),
                    fit: BoxFit.fill,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: height * 0.06,
                      ),
                      Container(
                          width: width * 0.55,
                          height: height * 0.15,
                          alignment: Alignment.bottomCenter,
                          child: SvgPicture.asset(
                              "assets/NAUTIC_RUS_White_logo.svg")),
                      SizedBox(
                        height: height * 0.06,
                      ),
                      Container(
                          padding: EdgeInsets.all(20),
                          width: width * 0.75,
                          height: height * 0.6,
                          decoration: BoxDecoration(
                              color: Colors.white70,
                              borderRadius: BorderRadius.circular(50)),
                          alignment: Alignment.center,
                          child: isLoading ? Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Image.asset(
                                "assets/no_connect.png",
                                width: width * 0.2,
                                height: height * 0.2,
                              ),
                              Text("No connection to deepsea.ru server",
                                  style: TextStyle(fontSize: 30),
                                  textAlign: TextAlign.center),
                              SizedBox(
                                height: height * 0.02,
                              ),
                              Text("Check your connection and refresh the page",
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
                                        isInternetConnected()
                                            .then((value) => status = value);
                                      });
                                    },
                                    child: Text("Refresh page"),
                                    style: ElevatedButton.styleFrom(
                                        textStyle: TextStyle(fontSize: 20)),
                                  )),
                            ],
                          ) : Container(
                            width: width,
                            height: height,
                            child: LoadingAnimationWidget.threeArchedCircle(
                                color: Color.fromARGB(255, 119, 134, 233),
                                size: MediaQuery.of(context).size.width * 0.2),
                          )
                        ),
                      SizedBox(
                        height: height * 0.02,
                      ),
                    ],
                  ),
                )),
          );
  }
}
