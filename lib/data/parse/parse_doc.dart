getSystemDescr(String systemDescr) {
  String? descr;
  RegExp exp = RegExp('[a-zA-Z ]+');
  Iterable<RegExpMatch> matches = exp.allMatches(systemDescr);
  for (final m in matches) {
    descr = m[0].toString();
  }

  print("$systemDescr parse to $descr");
  return descr;
}