import 'package:flutter/material.dart';

import '../internal/list_hullblocks.dart';
import '../internal/list_projects.dart';
import '../internal/list_spools.dart';

class RestPage extends StatefulWidget {
  const RestPage({Key? key}) : super(key: key);

  @override
  State<RestPage> createState() => _RestPageState();
}

class _RestPageState extends State<RestPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _kTabs = <Tab>[
    Tab(icon: Icon(Icons.directions_boat_outlined, color: Colors.black,), text: 'Проект', ),
    Tab(icon: Icon(Icons.file_present_outlined, color: Colors.black,), text: 'Чертежи'),
    Tab(icon: Icon(Icons.add_task_outlined, color: Colors.black,), text: 'Модели'),
  ];

  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = <Widget>[
    ListElements(),
    HullBlocks(),
    Spools()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _widgetOptions.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        children: _widgetOptions,
      ),
      bottomNavigationBar: Material(
        color: Colors.white,
        child: TabBar(
          tabs: _kTabs,
          controller: _tabController,
        ),
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: TabBarView(
  //       controller: _tabController,
  //       children: _widgetOptions,
  //     ),
  //     bottomNavigationBar: BottomNavigationBar(
  //       items: const <BottomNavigationBarItem>[
  //         BottomNavigationBarItem(
  //           icon: Icon(Icons.file_copy),
  //           label: 'Projects',
  //         ),
  //         BottomNavigationBarItem(
  //           icon: Icon(Icons.hourglass_full),
  //           label: 'HullBlocks',
  //         ),
  //         BottomNavigationBarItem(icon: Icon(Icons.dock), label: 'Spools')
  //       ],
  //       currentIndex: _selectedIndex,
  //       selectedItemColor: Colors.purple,
  //       onTap: _onItemTapped,
  //     ),
  //   );
  // }
}
