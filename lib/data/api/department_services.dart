import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

Future<List<String>> fetchDepartment() async {
  final response =
  await http.get(Uri.parse('https://deep-sea.ru/rest/issueDepartments'));
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return (jsonDecode(response.body) as List<dynamic>).cast<String>();
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load drawings');
  }
}