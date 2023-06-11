import 'dart:io';

Future<String> isInternetConnected() async {
  var res = "failed";
  try {
    final result = await InternetAddress.lookup('deep-sea.ru');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      print('connected to deepsea');
      res = "connect";
    }
  } on SocketException catch (_) {
    print('failed to deepsea');
  } on Exception catch (_) {
    print(_);
  }

  return res;
}