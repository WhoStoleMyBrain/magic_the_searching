import 'package:flutter/cupertino.dart';

import '../helpers/db_helper.dart';

class History with ChangeNotifier {
  List<HistoryObject> _data = [];

  List<HistoryObject> get data {
    return [..._data];
  }

  Future<void> getDBData(Function setInitToTrue) async {
    var historyData = await DBHelper.getHistoryData();
    setInitToTrue();
    _data = historyData;
    notifyListeners();
  }
}

class HistoryObject {
  String query;
  String matches;
  DateTime dateTime;
  List<String> languages;

  HistoryObject(
      {required this.query,
      required this.matches,
      required this.dateTime,
      required this.languages});

  factory HistoryObject.fromDB(Map<String, dynamic> json) => HistoryObject(
        query: json['searchText'].toString(),
        matches: json['matches'].toString(),
        dateTime: DateTime.parse(json['dateTime'].toString()),
        languages: json['languages'].toString().split(';'),
      );

  Map<String, dynamic> toDB() {
    return {
      'searchText': query,
      'count': matches,
      'requestTime': dateTime,
      'languages': languages.join(';'),
    };
  }
}
