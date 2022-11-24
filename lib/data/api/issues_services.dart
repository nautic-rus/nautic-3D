import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

Future<List<IssuesData>> fetchIssues() async {
  var url = 'https://deep-sea.ru/rest/issues?user=op';
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    return (jsonDecode(response.body) as Iterable)
        .map((e) => IssuesData.fromJson(e))
        .toList();
  } else {
    return
    throw Exception('Failed to load projects');
  }
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
