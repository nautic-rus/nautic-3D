import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
    );

    return MaterialApp(
      title: 'Introduction screen',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: PullRefreshPage(),
    );
  }
}

class PullRefreshPage extends StatefulWidget {
  const PullRefreshPage();

  @override
  State<PullRefreshPage> createState() => _PullRefreshPageState();
}

class _PullRefreshPageState extends State<PullRefreshPage> {
  List<String> numbersList = NumberGenerator().numbers;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _pullRefresh,
        child: ListView.builder(
          itemCount: numbersList.length,
          itemBuilder: (context, index) {
            return Text(
              "Your last scan data",
              style: TextStyle(fontSize: 30),
              textAlign: TextAlign.center,
              maxLines: 1,
            );
          },
        ),
      ),
    );
  }

  Future<void> _pullRefresh() async {
    List<String> freshNumbers = await NumberGenerator().slowNumbers();
    setState(() {
      numbersList = freshNumbers;
    });
    // why use freshNumbers var? https://stackoverflow.com/a/52992836/2301224
  }
}

class NumberGenerator {
  Future<List<String>> slowNumbers() async {
    return Future.delayed(
      const Duration(milliseconds: 1000),
      () => numbers,
    );
  }

  List<String> get numbers => List.generate(5, (index) => number);

  String get number => Random().nextInt(99999).toString();
}
