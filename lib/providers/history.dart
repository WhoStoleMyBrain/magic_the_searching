import 'package:flutter/cupertino.dart';

import '../helpers/db_helper.dart';

class History with ChangeNotifier {
  List<HistoryObject> _data = [];

  List<HistoryObject> get data {
    return [..._data];
  }

  void setDummyData() {
    _data = [
      HistoryObject(query: 'demon', matches: '13', dateTime: DateTime.now()),
      HistoryObject(query: 'Myojin', matches: '10', dateTime: DateTime.now()),
      HistoryObject(query: 'island', matches: '44', dateTime: DateTime.now()),
      HistoryObject(query: 'demon', matches: '13', dateTime: DateTime.now()),
      HistoryObject(query: 'Myojin', matches: '10', dateTime: DateTime.now()),
      HistoryObject(query: 'island', matches: '44', dateTime: DateTime.now()),
      HistoryObject(query: 'demon', matches: '13', dateTime: DateTime.now()),
      HistoryObject(query: 'Myojin', matches: '10', dateTime: DateTime.now()),
      HistoryObject(query: 'island', matches: '44', dateTime: DateTime.now()),
      HistoryObject(query: 'demon', matches: '13', dateTime: DateTime.now()),
      HistoryObject(query: 'Myojin', matches: '10', dateTime: DateTime.now()),
      HistoryObject(query: 'island', matches: '44', dateTime: DateTime.now()),
    ];
  }

  //List<HistoryObject>
  Future<void> getDBData() async {
    List<HistoryObject> data = [];
    var historyData = await DBHelper.getHistoryData();
    // print(historyData.toString());
    for (var historyElement in historyData) {
      data.add(
        HistoryObject(
          query: historyElement['searchText'].toString(),
          matches: historyElement['count'].toString(),
          dateTime: DateTime.parse(historyElement['requestTime'].toString()),
        ),
      );
    }
    // data = data.reversed.toList();
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
