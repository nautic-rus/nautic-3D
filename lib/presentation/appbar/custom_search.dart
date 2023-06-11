import 'package:flutter/material.dart';

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

  @override
  List<Widget>? buildActions(BuildContext context) {
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
      onPressed: () {
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
}
