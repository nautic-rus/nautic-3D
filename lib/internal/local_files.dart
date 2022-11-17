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
