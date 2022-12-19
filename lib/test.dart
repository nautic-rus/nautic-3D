import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: EmptyAppBar(),
        body: CustomScrollView(
          slivers: <Widget>[
            SliverPersistentHeader(
              delegate: MySliverAppBar(),
              floating: false,
              pinned: true,
            ),
            sliverBody()
          ],
        ));
  }
}

class MySliverAppBar extends SliverPersistentHeaderDelegate {

  final double expandedHeight = 180;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {

    return Stack(
      clipBehavior: Clip.none, fit: StackFit.expand,
      children: [
        Image.network(
          "https://images.pexels.com/photos/396547/pexels-photo-396547.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500",
          fit: BoxFit.cover,
        ),
        Opacity(
          opacity: shrinkOffset / expandedHeight,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
            ),
          ),
        ),
        Center(
          child: Opacity(
            opacity: shrinkOffset / expandedHeight,
            child: Text(
              "MySliverAppBar",
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w700,
                fontSize: 23,
              ),
            ),
          ),
        ),
        Positioned(
          top: expandedHeight / 2 - shrinkOffset,
          left: MediaQuery.of(context).size.width / 4,
          child: Opacity(
            opacity: (1 - shrinkOffset / expandedHeight),
            child: Card(
              elevation: 10,
              child: SizedBox(
                height: expandedHeight,
                width: MediaQuery.of(context).size.width / 2,
                child: FlutterLogo(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => kToolbarHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}

Widget sliverBody() {
  return SliverList(
    delegate: SliverChildListDelegate([
      ListTile(title: Text("1")),
      ListTile(title: Text("2")),
      ListTile(title: Text("3")),
      ListTile(title: Text("4")),
      ListTile(title: Text("5")),
      ListTile(title: Text("6")),
      ListTile(title: Text("7")),
      ListTile(title: Text("8")),
      ListTile(title: Text("9")),
      ListTile(title: Text("10")),
      ListTile(title: Text("11")),
      ListTile(title: Text("12")),
      ListTile(title: Text("13")),
      ListTile(title: Text("14")),
      ListTile(title: Text("15")),
      ListTile(title: Text("16")),
      ListTile(title: Text("17")),
    ]),
  );
}

class  EmptyAppBar  extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
  @override
  Size get preferredSize => Size(0.0,0.0);
}