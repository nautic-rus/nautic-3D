import 'package:flutter/material.dart';

import '../../data/api/documents_services.dart';
import '../datascreens/data_from_scanner.dart';

class CustomSearchDelegate extends SearchDelegate {
  CustomSearchDelegate(
      {Key? key,
        required this.data,
        required this.futureDocs,
        required this.connectionState});

  List data;
  List<DocData> futureDocs;
  String connectionState;

  // Demo list to show querying
  List<String> searchTerms = [
    "210101-819-0001",
    "Banana",
    "Mango",
    "Pear",
    "Watermelons",
    "Blueberries",
    "Pineapples",
    "Strawberries"
  ];

  // first overwrite to
  // clear the search text
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
    for (var fruit in searchTerms) {
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
    for (var fruit in searchTerms) {
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
