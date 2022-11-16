import 'package:flutter/material.dart';
import 'package:nautic_viewer/presentation/qr_reader.dart';
import 'package:nautic_viewer/presentation/selectmodel.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var titleAppBar = Text("Nautic 3D");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: titleAppBar,
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
                    title: Text("Выбор модели"),
                    leading: Icon(Icons.directions_boat),
                    onTap: () {
                      setState(() {
                        titleAppBar = Text("Выбор модели");
                        Navigator.pop(context);
                        body = SelectModel();
                      });
                    },
                  ),
                  ListTile(
                    title: Text("QR сканнер"),
                    leading: Icon(Icons.qr_code_scanner),
                    onTap: () {
                      setState(() {
                        titleAppBar = Text("QR сканнер");
                        Navigator.pop(context);
                        body = QrReader();
                      });
                    },
                  ),
                  AboutListTile(
                    // <-- SEE HERE
                    icon: Icon(
                      Icons.info,
                    ),
                    child: Text('О приложении'),
                    applicationIcon: Icon(
                      Icons.local_play,
                    ),
                    applicationName: 'Nautic 3D',
                    applicationVersion: '1.1.0',
                    applicationLegalese: '© 2022 Наутик Рус',
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

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
}
