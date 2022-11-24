import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../palette/palette.dart';
import '../presentation/splash_screen.dart';

class Application extends StatelessWidget {
  const Application({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // builder: (context, child) => ResponsiveWrapper.builder(
      //     BouncingScrollWrapper.builder(context, child!),
      //     maxWidth: 1200,
      //     minWidth: 450,
      //     defaultScale: true,
      //     breakpoints: [
      //       const ResponsiveBreakpoint.resize(450, name: MOBILE),
      //       const ResponsiveBreakpoint.autoScale(800, name: TABLET),
      //       const ResponsiveBreakpoint.autoScale(1000, name: TABLET),
      //       const ResponsiveBreakpoint.resize(1200, name: DESKTOP),
      //       const ResponsiveBreakpoint.autoScale(2460, name: "4K"),
      //     ],
      //     background: Container(color: const Color(0xFFF5F5F5))),
      title: 'Nautic 3D',
      theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: Colors.white,
          primarySwatch: Palette.kToLight,
          primaryColorLight: Colors.white,
          primaryColorDark: Colors.white,
          useMaterial3: true),
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
