import 'package:flutter/material.dart';
import 'package:nautic_viewer/presentation/qr_reader.dart';
import 'package:nautic_viewer/presentation/select_spool.dart';

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
                    title: Text("Spool selection"),
                    leading: Icon(Icons.directions_boat),
                    onTap: () {
                      setState(() {
                        titleAppBar = Text("Spool selection");
                        Navigator.pop(context);
                        body = SelectSpool(
                          docNumber: "210101-819-0001",
                        );
                      });
                    },
                  ),
                  ListTile(
                    title: Text("QR scanner"),
                    leading: Icon(Icons.qr_code_scanner),
                    onTap: () {
                      setState(() {
                        titleAppBar = Text("QR scanner");
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
                    child: Text('About application'),
                    applicationIcon: Icon(
                      Icons.local_play,
                    ),
                    applicationName: 'Nautic 3D',
                    applicationVersion: '1.3.1',
                    applicationLegalese: '© 2022 Nautic Rus',
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
      alignment: Alignment.center,
      color: Color.fromARGB(254, 254, 254, 255),
      child: Image.asset("assets/giphy.gif"),
    ),
  );
}
