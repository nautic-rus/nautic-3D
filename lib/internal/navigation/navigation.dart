import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../connection/if_not_connection.dart';
import '../../presentation/navigation/home_page_screen.dart';
import '../../presentation/navigation/qr_reader_screen.dart';
import '../../presentation/navigation/sel_doc_screen.dart';

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
  late double multiplier;

  final _kTabPages = <Widget>[
    CheckConnectionPage(page: Home()),
    CheckConnectionPage(page: QrReader()),
    CheckConnectionPage(page: SelectModel()),
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
      type: BottomNavigationBarType.fixed,
      onTap: _onItemTapped,
      items: _kBottomNavBarItems,
      iconSize: height * 0.025,
    );

    return WillPopScope(
        child: Scaffold(
          key: _scaffoldKey,
          body: _kTabPages[_selectedIndex],
          // body: IndexedStack(
          //   children: _kTabPages,
          //   index: _selectedIndex,
          // ),
          bottomNavigationBar: SizedBox(
            height: MediaQuery.of(context).size.height * 0.065,
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
