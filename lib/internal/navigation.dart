import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nautic_viewer/presentation/select_spool.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import '../presentation/history.dart';
import '../presentation/home.dart';
import '../presentation/qr_reader.dart';
import '../presentation/settings.dart';

class Navigation extends StatefulWidget {
  const Navigation({Key? key}) : super(key: key);

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var titleAppBar = Text("Nautic 3D");
  var _currentIndex = 0;
  List indexes = [];
  late TabController _tabController;

  late double width;
  late double height;
  late double unitHeightValue;
  late double multiplier;

  final _kTabPages = <Widget>[
    Home(),
    QrReader(),
    History(
      docNumber: "210101-819-0001",
    ),
    Settings()
  ];

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    if (width > height) {
      width = height;
      height = MediaQuery.of(context).size.width;
    }

    unitHeightValue = height * 0.01;
    multiplier = 1;

    final _kBottomNavBarItems = <SalomonBottomBarItem>[
      SalomonBottomBarItem(
        icon: Icon(
          Icons.home_outlined,
          size: width * 0.07,
        ),
        title: Text(
          "Home",
        ),
        selectedColor: Color.fromARGB(255, 119, 134, 233),
      ),
      SalomonBottomBarItem(
          icon: Icon(
            Icons.qr_code_scanner_outlined,
            size: width * 0.07,
          ),
          title: Text("QR scanner"),
          selectedColor: Color.fromARGB(255, 119, 134, 233)),
      SalomonBottomBarItem(
          icon: Icon(
            Icons.history_outlined,
            size: width * 0.07,
          ),
          title: Text("History"),
          selectedColor: Color.fromARGB(255, 119, 134, 233)),
      SalomonBottomBarItem(
          icon: Icon(
            Icons.info_outline,
            size: width * 0.07,
          ),
          title: Text("Information"),
          selectedColor: Color.fromARGB(255, 119, 134, 233)),
    ];

    final bottomNavBar = SalomonBottomBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() {
        indexes.add(_currentIndex);
        _currentIndex = index;
      }),
      items: _kBottomNavBarItems,
    );

    return WillPopScope(
        child: Scaffold(
          key: _scaffoldKey,
          body: _kTabPages[_currentIndex],
          bottomNavigationBar: SizedBox(
            height: MediaQuery.of(context).size.height * 0.08,
            width: MediaQuery.of(context).size.width,
            child: bottomNavBar,
          ),
        ),
        onWillPop: () async {
          setState(() {
            if (indexes.length > 0) {
              setState(() {
                _currentIndex = indexes[indexes.length - 1];
                indexes.removeLast();
              });
            } else {
              SystemChannels.platform.invokeMethod('SystemNavigator.pop');
            }
          });
          return false;
        });
  }
}
