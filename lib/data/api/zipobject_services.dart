import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<Archive> fetchFiles(String url) async {
  WidgetsFlutterBinding.ensureInitialized();

  var data = getData(url);

  final response = await http.get(Uri.parse(getUrl(data)));

  final archive = ZipDecoder().decodeBytes(response.bodyBytes);
  return archive;
}

getData(String url) {
  List data = ['', '', '0'];
  RegExp exp = RegExp('(?<=\=)[^&]+');
  Iterable<RegExpMatch> matches = exp.allMatches(url);
  int i = 0;
  for (final m in matches) {
    data[i] = m[0];
    i++;
  }

  return data;
}

validateUrl(String url) {
  var data = getData(url);
  if (data[0] == "" || data[1] == "") {
    print("nononnonnononon");
    return false;
  } else {
    print("yeyseysyeysyeyse");
    return true;
  }
}

getUrl(List data) {
  var url =
      'https://deep-sea.ru/rest-spec/spoolFiles?docNumber=${data[0]}&spool=${data[1]}&isom=${data[2]}';
  return url;
}
