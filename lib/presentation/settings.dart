import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          alignment: Alignment.center,
          child: Text(
            "Write an email to the developer with feedback about the application\n\nmail: mamonov@nautic-rus.ru",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30),
          )),
    );
  }
}
