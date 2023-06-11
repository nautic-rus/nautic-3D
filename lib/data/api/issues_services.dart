import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tuple/tuple.dart';

Future<Tuple2<List<IssuesData>, String>> fetchIssues() async {
  var url = 'https://deep-sea.ru/rest/issues?user=op';
  String connectionState = "failed";
  List<IssuesData> data = [];
  Tuple2<List<IssuesData>, String> answer;

  print("start connection issues");

  try {
    final response =
        await http.get(Uri.parse(url)).timeout(const Duration(seconds: 30));
    print("end connection issues");
    if (response.statusCode == 200) {
      data = (jsonDecode(response.body) as Iterable)
          .map((e) => IssuesData.fromJson(e))
          .toList();
      connectionState = "connect";
      if (data.isEmpty) connectionState = "empty";
    }
  } on TimeoutException {
    print("connection timeout");
  }
  answer = Tuple2(data, connectionState);
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

  factory IssuesData.fromJson(
      Map<String, dynamic> json) {
    return IssuesData(
      project: json['project'],
      department: json['department'],
      issue_type: json['issue_type'],
      doc_number: json['doc_number'],
    );
  }
}
