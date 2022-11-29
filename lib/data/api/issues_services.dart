import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tuple/tuple.dart';

Future<Tuple2<List<IssuesData>, bool>> fetchIssues() async {
  var url = 'https://deep-sea.ru/rest/issues?user=op';
  Tuple2<List<IssuesData>, bool> answer =
      Tuple2<List<IssuesData>, bool>([], false);
  print("start connection issues");
  try {
    final response =
        await http.get(Uri.parse(url)).timeout(const Duration(seconds: 20));
    if (response.statusCode == 200) {
      answer = Tuple2<List<IssuesData>, bool>(
          (jsonDecode(response.body) as Iterable)
              .map((e) => IssuesData.fromJson(e))
              .toList(),
          true);
    }
  } on TimeoutException {
    print("connection timeout");
  }

  return answer;
}

class IssuesData {
  final String project;
  final String department;
  final String issue_type;
  final String doc_number;

  const IssuesData(
      {required this.project,
      required this.department,
      required this.issue_type,
      required this.doc_number});

  factory IssuesData.fromJson(Map<String, dynamic> json) {
    return IssuesData(
      project: json['project'],
      department: json['department'],
      issue_type: json['issue_type'],
      doc_number: json['doc_number'],
    );
  }
}
