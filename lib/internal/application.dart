import 'package:flutter/material.dart';

import '../presentation/home.dart';
import '../presentation/selectmodel.dart';
import '../presentation/splash_screen.dart';

class Application extends StatelessWidget {
  const Application({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nautic 3D',
      theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          useMaterial3: true),
      home: SplashScreen(),
    );
  }
}
