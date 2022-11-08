import 'package:flutter/material.dart';

import '../internal/list_hullblocks.dart';
import '../internal/list_projects.dart';
import '../internal/list_spools.dart';

class RestPage extends StatefulWidget {
  const RestPage({Key? key}) : super(key: key);

  @override
  State<RestPage> createState() => _RestPageState();
}

class _RestPageState extends State<RestPage> {
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.file_copy),
            label: 'Projects',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.hourglass_full),
            label: 'HullBlocks',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.dock), label: 'Spools')
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.purple,
        onTap: _onItemTapped,
      ),
    );
  }
}
