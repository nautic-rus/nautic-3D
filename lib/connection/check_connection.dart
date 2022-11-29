import 'dart:io';

Future<bool> isInternetConnected() async {
  try {
    final result = await InternetAddress.lookup('deep-sea.ru');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      print('connected');
      return true;
    } else {
      return false;
    }
  } on SocketException catch (_) {
    print('not connected');
    return false;
  }
}