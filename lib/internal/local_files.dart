import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart' as path_provider;

Future<File> _getLocalFile(String kLocalFileName) async {
  final directory = await path_provider.getApplicationDocumentsDirectory();
  return File('${directory.path}/$kLocalFileName');
}

Future<File> _writeTextToLocalFile(String text, String kLocalFileName) async {
  final file = await _getLocalFile(kLocalFileName);
  return file.writeAsString(text);
}

Future<String> _loadTextFromLocalFile(String kLocalFileName) async {
  String content;
  try {
    final file = await _getLocalFile(kLocalFileName);
    content = await file.readAsString();
  } catch (e) {
    content = 'Error loading local file: $e';
  }

  return content;
}

getLastScanUrl() async {
  String kLocalFileName = 'file_last_qr_url_localfile.txt';

  String url = "";

  await _loadTextFromLocalFile(kLocalFileName).then((value) => {url = value});
  return url;
}

saveLastScanUrl(String url) {
  String kLocalFileName = 'file_last_qr_url_localfile.txt';

  _writeTextToLocalFile(url, kLocalFileName);
}

getDocumentsHistory() async {
  String kLocalFileName = 'file_last_documents_localfile.txt';

  List documents = [];

  await _loadTextFromLocalFile(kLocalFileName).then(
      (value) => {documents = json.decode(value).cast<String>().toList()});

  print(documents);

  return documents;
}

saveLastDocuments(String documents) async {
  List<String> docs = [];
  String kLocalFileName = 'file_last_documents_localfile.txt';
  print(docs);
  _writeTextToLocalFile(docs.toString(), kLocalFileName);

  await getDocumentsHistory()
      .then((value) => {docs = json.decode(value).cast<String>().toList()});

  docs.add(documents);

  print(docs);
  _writeTextToLocalFile(docs.toString(), kLocalFileName);
}
