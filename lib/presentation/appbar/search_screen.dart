import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double appBarHeight = 50.0;

    return Scaffold(
        appBar: PreferredSize(
      preferredSize: Size.fromHeight(appBarHeight),
      child: AppBar(
          // The search area here
          title: Container(
        height: appBarHeight * 0.9,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
        child: Center(
          child: TextField(
            decoration: InputDecoration(
                hintText: 'SFI-drawing no.', border: InputBorder.none),
          ),
        ),
      )),
    ));
  }
}
