import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nautic_viewer/presentation/qr_reader.dart';
import 'package:nautic_viewer/presentation/select_spool.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import '../presentation/home.dart';
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

  final _kTabPages = <Widget>[
    Home(),
    QrReader(),
    SelectSpool(
      docNumber: "210101-819-0001",
    ),
    Settings()
  ];

  final _kBottomNavBarItems = <SalomonBottomBarItem>[
    SalomonBottomBarItem(
        icon: Icon(Icons.home),
        title: Text("Home"),
        selectedColor: Colors.deepPurple),
    SalomonBottomBarItem(
        icon: Icon(Icons.qr_code_scanner),
        title: Text("QR scanner"),
        selectedColor: Colors.deepPurple),
    SalomonBottomBarItem(
        icon: Icon(Icons.directions_boat),
        title: Text("Documents"),
        selectedColor: Colors.deepPurple),
    SalomonBottomBarItem(
        icon: Icon(Icons.settings),
        title: Text("Settings"),
        selectedColor: Colors.deepPurple),
  ];

  @override
  Widget build(BuildContext context) {
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
          bottomNavigationBar: bottomNavBar,
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
