import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../data/api/documents_services.dart';
import '../../data/api/issues_services.dart';
import '../datascreens/data_from_scanner.dart';

class CustomSearchDelegate extends SearchDelegate {
  CustomSearchDelegate(
      {Key? key,
        required this.data,
        required this.futureDocs,
        required this.connectionState,
        required this.documents});

  List data;
  List<DocData> futureDocs;
  String connectionState;
  List<String> documents;

  var brightness;
  late double width;

  @override
  List<Widget>? buildActions(BuildContext context) {
    brightness = SchedulerBinding.instance.window.platformBrightness;
    width = MediaQuery.of(context).size.width;

    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear),
      ),
    ];
  }

  // second overwrite to pop out of search menu
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () async {
        FocusManager.instance.primaryFocus?.unfocus();
        await Future.delayed(Duration(milliseconds: 150));
        close(context, null);
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  // third overwrite to show query result
  @override
  Widget buildResults(BuildContext context) {
    List<String> matchQuery = [];
    for (var fruit in documents) {
      if (fruit.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(fruit);
      }
    }
    return documents.isNotEmpty ? ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
            title: Text(result),
            onTap: () {
              data[0] = result;
              data[1] = "001";
              Navigator.of(context)
                  .push(MaterialPageRoute(
                  builder: (context) => Document(
                    data: data,
                    futureDocs: futureDocs,
                    connectionState: connectionState,
                  )));
            });
      },
    ) : isLoading();
  }

  // last overwrite to show the
  // querying process at the runtime
  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> matchQuery = [];
    for (var fruit in documents) {
      if (fruit.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(fruit);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
            title: Text(result),
            onTap: () {
              data[0] = result;
              data[1] = "001";
              Navigator.of(context)
                  .push(MaterialPageRoute(
                  builder: (context) => Document(
                    data: data,
                    futureDocs: futureDocs,
                    connectionState: connectionState,
                  )));
            });
      },
    );
  }

  Widget isLoading() {
    return Center(
        child: LoadingAnimationWidget.threeArchedCircle(
            color: brightness == Brightness.dark
                ? Color(0xFF67CAD7)
                : Color(0xFF2C298A),
            size: width * 0.2));
  }
}
