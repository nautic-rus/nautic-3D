import 'package:tuple/tuple.dart';

import '../api/documents_services.dart';

parseSpool(String docNumber) async {
  List<DocData> futureSpool = List<DocData>.empty(growable: true);
  List<String> spoolsList = List<String>.empty(growable: true);

  String connection = "failed";
  try {
    await fetchDocument(docNumber).then((value) => {
      connection = value.item2,
      value.item1.forEach((element) {
        print(element);
        futureSpool.add(element);
      })
    });
  } on Exception catch (_) {
    print(_);
  }

  print(connection);
  for (int i = 0; i < futureSpool.length; i++) {
    spoolsList.add(futureSpool[i].spool);
  }

  // spoolsInt = spoolsList.map(int.parse).toSet().toList();
  // spoolsInt.sort();

  spoolsList.removeWhere((element) => element == "");
  spoolsList.sort((a, b) => addLeftZeros(a).compareTo(addLeftZeros(b)));

  List<String> dis = [];
  spoolsList.toSet().forEach((element) {
    dis.add(element);
  });

  return Tuple2(dis, connection);
}

parseFullSpool(String docNumber) async {
  List<DocData> futureSpool = List<DocData>.empty(growable: true);
  List<String> spoolsList = List<String>.empty(growable: true);

  await fetchDocument(docNumber).then((value) => {
        value.item1.forEach((element) {
          futureSpool.add(element);
        })
      });

  for (int i = 0; i < futureSpool.length; i++) {
    spoolsList.add(futureSpool[i].spool);
  }

  List<String> dis = [];
  spoolsList.forEach((element) {
    dis.add(element);
  });

  return dis;
}

parseSqInSystem(String docNumber) async {
  List<DocData> futureSpool = List<DocData>.empty(growable: true);
  List<String> sqList = List<String>.empty(growable: true);

  await fetchDocument(docNumber).then((value) => {
        value.item1.forEach((element) {
          futureSpool.add(element);
        })
      });

  for (int i = 0; i < futureSpool.length; i++) {
    sqList.add(futureSpool[i].sqInSystem.toString());
  }

  List<String> dis = [];
  sqList.forEach((element) {
    dis.add(element);
  });

  return dis;
}

sqInSystemToSpool(String docNumber, String sqInSystem) async {
  List<DocData> futureSpool = List<DocData>.empty(growable: true);
  List<String> spoolsList = List<String>.empty(growable: true);
  List<int> sqList = List<int>.empty(growable: true);
  String spool = "null";

  print(sqInSystem);

  await fetchDocument(docNumber).then((value) => {
        value.item1.forEach((element) {
          futureSpool.add(element);
        }),
      });

  for (int i = 0; i < futureSpool.length; i++) {
    spoolsList.add(futureSpool[i].spool);
    sqList.add(futureSpool[i].sqInSystem);
  }

  for (int i = 0; i < spoolsList.length; i++) {
    if (sqInSystem == sqList[i].toString()) {
      spool = spoolsList[i];
    }
  }

  return spool;
}

zerosInList() {}

int sortSpools(String x1, String x2) {
  return addLeftZeros(x1).compareTo(addLeftZeros(x2));
}

String addLeftZeros(String input, {int length = 10}) {
  String res = input;
  while (res.length < length) {
    res = "0$res";
  }
  return res;
}
