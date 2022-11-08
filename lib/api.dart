import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<Archive> fetchFiles(String url) async {
  WidgetsFlutterBinding.ensureInitialized();

  List data = ['', '', '0'];
  RegExp exp = RegExp('(?<=\=)[^&]+');
  Iterable<RegExpMatch> matches = exp.allMatches(url);
  int i = 0;
  for (final m in matches) {
    data[i] = m[0];
    i++;
  }

  var getUrl =
      'https://deep-sea.ru/rest-spec/spoolFiles?docNumber=${data[0]}&spool=${data[1]}&isom=${data[2]}';

  final response = await http.get(Uri.parse(getUrl));

  final archive = ZipDecoder().decodeBytes(response.bodyBytes);
  return archive;
}
