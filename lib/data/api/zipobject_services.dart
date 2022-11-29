import 'dart:async';
import 'dart:collection';

import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tuple/tuple.dart';

Future<Tuple2<Archive, bool>> fetchFiles(String url) async {
  WidgetsFlutterBinding.ensureInitialized();

  var data = getData(url);
  print("start connection archive");
  Tuple2<Archive, bool> answer =  Tuple2<Archive, bool>(Archive(), false);
  try {
    final response = await http
        .get(Uri.parse(getUrl(data)))
        .timeout(const Duration(seconds: 5));
    print("end connection archive");
    if (response.statusCode == 200) {
      final archive = ZipDecoder().decodeBytes(response.bodyBytes);
      return Tuple2<Archive, bool>(archive, true);
    }
  } on TimeoutException {
    print("connection timeout");
  }

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
