import 'package:flutter/material.dart';
import 'package:nautic_viewer/presentation/qr_reader.dart';
import 'package:nautic_viewer/presentation/rest_page.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nautic 3D"),
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
