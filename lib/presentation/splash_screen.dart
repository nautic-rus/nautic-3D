import 'dart:io';

import 'package:flutter/material.dart';

import '../internal/navigation.dart';
import '../not_connection/nc_navigation.dart';
import 'package:http/http.dart' as http;
import 'home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isInternetAvailable = false;

  @override
  void initState() {
    isInternetConnected().then((value) {
      setState(() {
        isInternetAvailable = value;
      });
    });
    super.initState();
    _navigateToHome();
  }

  Future<bool> isInternetConnected() async {
    try {
      final result = await InternetAddress.lookup('deep-sea.ru');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        return true;
      } else {
        return false;
      }
    } on SocketException catch (_) {
      print('not connected');
      return false;
    }
  }

  Future<bool> isDeepseaConnected() async {
    var url = 'https://deep-sea.ru/rest/ping';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  _navigateToHome() async {
    await Future.delayed(Duration(milliseconds: 1500), () {});

    if (isInternetAvailable) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Navigation()));
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Navigation()));
    }
  }

  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Message'),
          content: const Text(
              'No connection to server, application functions are limited'),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Ok'),
              onPressed: () {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => Navigation()));
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Container(
            //   height: 100,
            //   width: 100,
            //   color: Colors.deepPurple,
            // ),
            Container(
              child: Text(
                'Nautic 3D',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
