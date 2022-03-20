import 'package:flutter/cupertino.dart';

import '../helpers/db_helper.dart';

class History with ChangeNotifier {
  List<HistoryObject> _data = [];

  List<HistoryObject> get data {
    return [..._data];
  }

  Future<void> getDBData(Function setInitToTrue) async {
    List<HistoryObject> data = [];
    var historyData = await DBHelper.getHistoryData();
    for (var historyElement in historyData) {
      data.add(
        HistoryObject(
          query: historyElement['searchText'].toString(),
          matches: historyElement['count'].toString(),
          dateTime: DateTime.parse(historyElement['requestTime'].toString()),
        ),
      );
    }
    setInitToTrue();
    _data = data;
    notifyListeners();
  }
}

class HistoryObject {
  String query;
  String matches;
  DateTime dateTime;

  HistoryObject(
      {required this.query, required this.matches, required this.dateTime});
}
