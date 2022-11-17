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
          primaryColor: Colors.white,
          primarySwatch: Colors.deepPurple,
          primaryColorLight: Colors.white,
          primaryColorDark: Colors.white,
          useMaterial3: true),
      home: SplashScreen(),
    );
  }
}
