import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'qr_reader.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Nautic 3D',
        initialRoute: '/',
        routes: <String, WidgetBuilder>{
          '/': (BuildContext context) => const HomeScreen(),
          '/rest': (BuildContext context) => const RestPage(),
          '/reader': (BuildContext context) => QrReader(),
        },
      );
    });
  }
}
