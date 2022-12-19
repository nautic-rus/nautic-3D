import 'dart:io';

Future<String> isInternetConnected() async {
  try {
    final result = await InternetAddress.lookup('deep-sea.ru');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      print('connected to deepsea');
      return "connect";
    } else {
      return "failed";
    }
  } on SocketException catch (_) {
    print('failed to deepsea');
    return "failed";
  }
}