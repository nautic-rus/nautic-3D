import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

Future<List<ProjectName>> fetchProjects() async {
  final response =
  await http.get(Uri.parse('https://deep-sea.ru/rest/projectNames'));
  if (response.statusCode == 200) {
    return (jsonDecode(response.body) as Iterable)
        .map((e) => ProjectName.fromJson(e))
        .toList();
  } else {
    throw Exception('Failed to load projects');
  }
}

class ProjectName {
  final String id;
  final String rkd;
  final String pdsp;
  final String foran;
  final String cloud;
  final String cloudRkd;

  const ProjectName(
      {required this.id,
        required this.rkd,
        required this.pdsp,
        required this.foran,
        required this.cloud,
        required this.cloudRkd});

  factory ProjectName.fromJson(Map<String, dynamic> json) {
    return ProjectName(
        id: json['id'],
        rkd: json['rkd'],
        pdsp: json['pdsp'],
        foran: json['foran'],
        cloud: json['cloud'],
        cloudRkd: json['cloudRkd']);
  }
}
