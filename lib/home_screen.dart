import 'package:flutter/material.dart';

import 'hullBlock.dart';
import 'foran_project.dart';
import 'qr_reader.dart';
import 'package:sizer/sizer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  Widget body = Scaffold(
    body: Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/sea.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: null,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("rest"),
      ),
      body: Center(
        child: Container(
          child: body,
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            Container(
              child: DrawerHeader(
                child: Container(),
              ),
            ),
            Container(
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: Text("Rest"),
                    leading: Icon(Icons.api),
                    onTap: () {
                      setState(() {
                        Navigator.pop(context);
                        body = RestPage();
                      });
                    },
                  ),
                  ListTile(
                    title: Text("QrReader"),
                    leading: Icon(Icons.hourglass_full),
                    onTap: () {
                      setState(() {
                        Navigator.pop(context);
                        body = QrReader();
                      });
                    },
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class RestPage extends StatefulWidget {
  const RestPage({Key? key}) : super(key: key);

  @override
  State<RestPage> createState() => _RestPageState();
}

class _RestPageState extends State<RestPage> {
  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = <Widget>[
    ListElements(),
    HullBlocks()
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
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.purple,
        onTap: _onItemTapped,
      ),
    );
  }
}

class ListElements extends StatefulWidget {
  const ListElements({Key? key}) : super(key: key);

  @override
  State<ListElements> createState() => _ListElementsState();
}

class _ListElementsState extends State<ListElements> {
  List<ProjectName> futureProjectName = List<ProjectName>.empty(growable: true);

  int selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    fetchProjects().then((value) => {
      setState(() {
        value.forEach((element) {
          futureProjectName.add(element);
        });
      })
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(selectedIndex == -1
            ? "NO"
            : "id: ${futureProjectName[selectedIndex].id}\n"
            "rkd: ${futureProjectName[selectedIndex].rkd}\n"
            "pdsp: ${futureProjectName[selectedIndex].pdsp}\n"
            "foran: ${futureProjectName[selectedIndex].foran}\n"
            "cloud: ${futureProjectName[selectedIndex].cloud}\n"
            "cloudRkd: ${futureProjectName[selectedIndex].cloudRkd}\n"),
        Expanded(
            child: ListView.builder(
              itemBuilder: _createListView,
              itemCount: futureProjectName.length,
            ))
      ],
    );
  }

  Widget _createListView(BuildContext context, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        padding: EdgeInsets.symmetric(vertical: 8),
        color: index == selectedIndex ? Colors.black12 : Colors.white60,
        child: Text(futureProjectName[index].foran,
            style: TextStyle(fontSize: 24)),
      ),
    );
  }
}

class HullBlocks extends StatefulWidget {
  const HullBlocks({Key? key}) : super(key: key);

  @override
  State<HullBlocks> createState() => _HullBlocksState();
}

class _HullBlocksState extends State<HullBlocks> {
  List<Code> futureCode = List<Code>.empty(growable: true);

  int selectedIndex = -1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchCode().then((value) => {
      setState(() {
        value.forEach((element) {
          futureCode.add(element);
        });
      })
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(selectedIndex == -1
            ? "NO"
            : "OID: ${futureCode[selectedIndex].oid}\n"
            "CODE: ${futureCode[selectedIndex].code}\n"
            "DESCRIPTION: ${futureCode[selectedIndex].description}\n"),
        Expanded(
            child: ListView.builder(
              itemBuilder: _createListView,
              itemCount: futureCode.length,
            ))
      ],
    );
  }

  Widget _createListView(BuildContext context, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        padding: EdgeInsets.symmetric(vertical: 8),
        color: index == selectedIndex ? Colors.black12 : Colors.white60,
        child: Text(futureCode[index].code, style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
