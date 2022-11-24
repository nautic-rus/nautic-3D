import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

Future<List<SpoolData>> fetchSpool(String docNumber) async {
  var url = 'https://deep-sea.ru/rest-spec/pipeSegs?docNumber=$docNumber';
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    return (jsonDecode(response.body) as Iterable)
        .map((e) => SpoolData.fromJson(e))
        .toList();
  } else {
    throw Exception('Failed to load projects');
  }
}

class SpoolData {
  final String spool;
  final int sqInSystem;

  const SpoolData({required this.spool, required this.sqInSystem});

  factory SpoolData.fromJson(Map<String, dynamic> json) {
    return SpoolData(
      spool: json['spool'],
      sqInSystem: json['sqInSystem'],
    );
  }
}
