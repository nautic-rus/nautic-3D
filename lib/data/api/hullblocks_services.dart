import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

Future<List<Code>> fetchCode() async {
  final response = await http
      .get(Uri.parse('https://deep-sea.ru/rest-spec/hullBlocks?project=N004'));
  if (response.statusCode == 200) {
    return (jsonDecode(response.body) as Iterable)
        .map((e) => Code.fromJson(e))
        .toList();
  } else {
    throw Exception('Failed to load data');
  }
}

class Code {
  final int oid;
  final String code;
  final String description;

  const Code(
      {required this.oid, required this.code, required this.description});

  factory Code.fromJson(Map<String, dynamic> json) {
    return Code(
        oid: json['OID'], code: json['CODE'], description: json['DESCRIPTION']);
  }
}
