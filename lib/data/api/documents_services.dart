import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:tuple/tuple.dart';

Future<Tuple2<List<DocData>, String>> fetchDocument(String docNumber) async {
  var url = 'https://deep-sea.ru/rest-spec/pipeSegs?docNumber=$docNumber';
  print("start connection pipeSegs");
  String connectionState = "failed";
  List<DocData> data = [];
  Tuple2<List<DocData>, String> res;
  try {
    final response =
        await http.get(Uri.parse(url)).timeout(const Duration(seconds: 30));
    if (response.statusCode == 200 && response.body != 'null') {
      print("end connection pipeSegs");
      data = (jsonDecode(response.body)['elements'] as Iterable)
          .map((e) => DocData.fromJson(e))
          .toList();
      connectionState = "connect";
    }
    if (data.isEmpty) connectionState = "empty";
  } on TimeoutException {
    print("connection timeout");
  } on Exception catch (_) {
    print(_);
  }
  res = Tuple2(data, connectionState);

  return res;
}

class DocData {
  final String line;
  final String typeCode;
  final String typeDesc;
  final String compUserId;
  final String spool;
  final int sqInSystem;
  final String systemDescr;

  const DocData(
      {required this.line,
      required this.typeCode,
      required this.typeDesc,
      required this.compUserId,
      required this.systemDescr,
      required this.spool,
      required this.sqInSystem});

  factory DocData.fromJson(Map<String, dynamic> json) {
    return DocData(
      spool: json['spool'],
      sqInSystem: json['sqInSystem'],
      line: json['line'],
      typeCode: json['typeCode'],
      typeDesc: json['typeDesc'],
      compUserId: json['compUserId'],
      systemDescr: json['systemDescr'],
    );
  }
}
