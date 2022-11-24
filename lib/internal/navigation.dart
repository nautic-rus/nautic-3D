import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nautic_viewer/presentation/history.dart';

import '../not_connection/if_not_connection.dart';
import '../presentation/chose_document.dart';
import '../presentation/home.dart';
import '../presentation/qr_reader.dart';

class Navigation extends StatefulWidget {
  const Navigation({Key? key}) : super(key: key);

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var titleAppBar = Text("Nautic 3D");
  var _selectedIndex = 0;
  List indexes = [];
  late TabController _tabController;

  late double width;
  late double height;
  late double unitHeightValue;
  late double multiplier;

  final _kTabPages = <Widget>[
    NoConnectionPage(page: Home()),
    NoConnectionPage(page: QrReader()),
    NoConnectionPage(page: SelectModel()),
    // NoConnectionPage(page: History(docNumber: "meow"))
  ];

  void _onItemTapped(int index) {
    setState(() {
      indexes.add(_selectedIndex);
      _selectedIndex = index;
    });
  }

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

    final _kBottomNavBarItems = <BottomNavigationBarItem>[
      BottomNavigationBarItem(
          icon: Icon(
            Icons.home,
          ),
          label: "Home"),
      BottomNavigationBarItem(
          icon: Icon(Icons.qr_code_scanner), label: "QR scanner"),
      BottomNavigationBarItem(icon: Icon(Icons.file_copy), label: "Catalog"),
      // BottomNavigationBarItem(icon: Icon(Icons.history), label: "History")
    ];

    assert(_kTabPages.length == _kBottomNavBarItems.length);

    final bottomNavBar = BottomNavigationBar(
      currentIndex: _selectedIndex,
      unselectedItemColor: Colors.black,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Color.fromARGB(255, 119, 134, 233),
      onTap: _onItemTapped,
      items: _kBottomNavBarItems,
      iconSize: 30,
    );

    return WillPopScope(
        child: Scaffold(
          key: _scaffoldKey,
          body: _kTabPages[_selectedIndex],
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
                _selectedIndex = indexes[indexes.length - 1];
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
