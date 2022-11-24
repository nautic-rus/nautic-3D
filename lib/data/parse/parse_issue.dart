import '../api/issues_services.dart';

parseIssue(String project, String department) async {
  List<IssuesData> futureIssues = List<IssuesData>.empty(growable: true);
  List<String> documentList = [];

  await fetchIssues().then((value) => {
        value.forEach((element) {
          futureIssues.add(element);
        }),
      });

  for (int i = 0; i < futureIssues.length; i++) {
    if (futureIssues[i].department == department &&
        futureIssues[i].issue_type == "RKD" &&
        futureIssues[i].project == project) {
      documentList.add(futureIssues[i].doc_number);
    }
  }

  List<String> dis = [];
  documentList.toSet().forEach((element) {
    dis.add(element);
  });

  return dis;
}

parseProject() async {
  List<IssuesData> futureIssues = List<IssuesData>.empty(growable: true);
  List<String> projectsList = [];

  await fetchIssues().then((value) => {
        value.forEach((element) {
          futureIssues.add(element);
        }),
      });

  for (int i = 0; i < futureIssues.length; i++) {
    if (futureIssues[i].department == "System" &&
        futureIssues[i].issue_type == "RKD") {
      projectsList.add(futureIssues[i].project);
    }
  }

  List<String> dis = [];
  projectsList.toSet().forEach((element) {
    dis.add(element);
  });

  return dis;
}

parseDepartment(String project) async {
  List<IssuesData> futureIssues = List<IssuesData>.empty(growable: true);
  List<String> departmentList = [];

  await fetchIssues().then((value) => {
    value.forEach((element) {
      futureIssues.add(element);
    }),
  });

  for (int i = 0; i < futureIssues.length; i++) {
    if (futureIssues[i].department == "System" &&
        futureIssues[i].project == project) {
      departmentList.add(futureIssues[i].department);
    }
  }

  List<String> dis = [];
  departmentList.toSet().forEach((element) {
    dis.add(element);
  });

  return dis;
}


