import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../presentation/startapp/launch_screen.dart';

class Application extends StatelessWidget {
  const Application({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nautic 3D',
      theme: FlexThemeData.light(
          useMaterial3: true,
          colors: _myFlexScheme.light,
          appBarElevation: 0.5,
          useMaterial3ErrorColors: true,
          visualDensity: VisualDensity.standard,
          fontFamily: GoogleFonts.dmSans().fontFamily),
      darkTheme: FlexThemeData.dark(
        useMaterial3: true,
        colors: _myFlexScheme.dark,
        appBarElevation: 0.5,
        visualDensity: VisualDensity.standard,
        fontFamily: GoogleFonts.dmSans().fontFamily,
      ),
      themeMode: ThemeMode.system,
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

const FlexSchemeData _myFlexScheme = FlexSchemeData(
  name: 'Midnight blue',
  description: 'Midnight blue theme, custom definition of all colors',
  light: FlexSchemeColor(
    primary: Color(0xFF2C298A),
    primaryContainer: Color(0xFF2C298A),
    secondary: Color(0xFF67CAD7),
    secondaryContainer: Color(0xFFCFE4FF),
    tertiary: Color(0xFF00B0FF),
    tertiaryContainer: Color(0xFF9FCBF1),
  ),
  dark: FlexSchemeColor(
    primary: Color(0xFF67CAD7),
    primaryContainer: Color(0xFF1F9BAB),
    secondary: Color(0xFF67CAD7),
    secondaryContainer: Color(0xFFCFE4FF),
    tertiary: Color(0xFF00B0FF),
    tertiaryContainer: Color(0xFF9FCBF1),
  ),
);
