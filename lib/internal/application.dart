import 'package:flutter/material.dart';

import '../presentation/splash_screen.dart';

class Application extends StatelessWidget {
  const Application({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nautic 3D',
      theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: Colors.lightBlue,
          accentColor: Colors.green,
          primarySwatch: Colors.deepPurple,
          useMaterial3: true),
      home: SplashScreen(),
    );
  }
}
