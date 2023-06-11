import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../connection/if_not_connection.dart';
import '../../data/api/documents_services.dart';
import '../../data/api/issues_services.dart';
import '../../presentation/navigation/home_page_screen.dart';
import '../../presentation/navigation/qr_reader_screen.dart';
import '../../presentation/navigation/sel_doc_screen.dart';

class Navigation extends StatefulWidget {
  Navigation(
      {Key? key,
      required this.futureDocs,
      required this.futureIssues,
      required this.connectionState})
      : super(key: key);

  List<DocData> futureDocs;
  List<IssuesData> futureIssues;
  String connectionState;

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

  final PageStorageBucket bucket = PageStorageBucket();

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

    // if (width > height) {
    //   width = height;
    //   height = MediaQuery.of(context).size.width;
    // }

    multiplier = 1;

    final _kBottomNavBarItems = <BottomNavigationBarItem>[
      BottomNavigationBarItem(
          icon: Icon(
            Icons.home_outlined,
          ),
          label: "Home"),
      BottomNavigationBarItem(
          icon: Icon(Icons.qr_code_scanner_outlined), label: "QR scanner"),
      BottomNavigationBarItem(icon: Icon(Icons.file_copy_outlined), label: "Catalog"),
    ];

    final _kTabPages = <Widget>[
      Home(
          futureDocs: widget.futureDocs,
          connectionState: widget.connectionState,
          futureIssues: widget.futureIssues),
      QrReader(
        futureDocs: widget.futureDocs,
        connectionState: widget.connectionState,
      ),
      SelectModel(futureIssues: widget.futureIssues)
    ];

    assert(_kTabPages.length == _kBottomNavBarItems.length);

    Widget bottomNavBar(int selectedIndex) => BottomNavigationBar(
          currentIndex: selectedIndex,
          type: BottomNavigationBarType.fixed,
          onTap: _onItemTapped,
          items: _kBottomNavBarItems,
          iconSize: height * 0.04,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedFontSize: 0,
          unselectedFontSize: 0,
        );

    return WillPopScope(
        child: Scaffold(
          key: _scaffoldKey,
          body: PageStorage(
            bucket: bucket,
            child: _kTabPages[_selectedIndex],
          ),
          bottomNavigationBar: SizedBox(
            height: height * 0.065,
            width: width,
            child: bottomNavBar(_selectedIndex),
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
