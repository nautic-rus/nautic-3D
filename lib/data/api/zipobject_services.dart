import 'dart:async';

import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tuple/tuple.dart';

Future<Tuple2<Archive, String>> fetchFiles(String url) async {
  WidgetsFlutterBinding.ensureInitialized();

  var dataUrl = getData(url);
  print("start connection archive");
  String connectionState = "failed";
  Archive archive = Archive();
  Tuple2<Archive, String> answer;
  try {
    final response = await http
        .get(Uri.parse(getUrl(dataUrl)))
        .timeout(const Duration(seconds: 30));
    print("end connection archive");
    if (response.statusCode == 200) {
      archive = ZipDecoder().decodeBytes(response.bodyBytes);
      connectionState = "connect";
      if (archive.isEmpty) connectionState = "empty";
    }
  } on TimeoutException {
    print("connection timeout");
  }
  answer = Tuple2(archive, connectionState);
  return answer;
}

getData(String url) {
  List data = ['', '', '0'];
  RegExp exp = RegExp('(?<=\\=)[^&]+');
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
    return false;
  } else {
    return true;
  }
}

getUrl(List data) {
  var url =
      'https://deep-sea.ru/rest-spec/spoolFiles?docNumber=${data[0]}&spool=${data[1]}&isom=${data[2]}';
  return url;
}

getDocument(String url) {
  var data = getData(url);
  return data[0];
}

getSqInSystem(String filename) {
  String? name;
  RegExp exp = RegExp('\\d+(?=\\.obj\$)');
  Iterable<RegExpMatch> matches = exp.allMatches(filename);
  for (final m in matches) {
    name = m[0].toString();
  }

  print("$filename parse to $name");
  return name;
}
