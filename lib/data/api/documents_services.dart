import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tuple/tuple.dart';

Future<Tuple2<List<DocData>, bool>> fetchDocument(String docNumber) async {
  var url = 'https://deep-sea.ru/rest-spec/pipeSegs?docNumber=$docNumber';
  print("start connection pipeSegs");
  Tuple2<List<DocData>, bool> answer = Tuple2<List<DocData>, bool>([], false);
  try {
    final response =
        await http.get(Uri.parse(url)).timeout(const Duration(seconds: 20));
    if (response.statusCode == 200) {
      print("end connection pipeSegs");
      answer = Tuple2<List<DocData>, bool>(
          (jsonDecode(response.body) as Iterable)
              .map((e) => DocData.fromJson(e))
              .toList(),
          true);
    }
  } on TimeoutException {
    print("connection timeout");
  }

  return answer;
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
