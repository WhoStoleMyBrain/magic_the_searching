import 'package:flutter/cupertino.dart';

import '../helpers/db_helper.dart';

class History with ChangeNotifier {
  List<HistoryObject> _data = [];

  List<HistoryObject> get data {
    return [..._data];
  }

  void setDummyData() {
    _data = [
      HistoryObject(query: 'demon', matches: '13'),
      HistoryObject(query: 'Myojin', matches: '10'),
      HistoryObject(query: 'island', matches: '44'),
      HistoryObject(query: 'demon', matches: '13'),
      HistoryObject(query: 'Myojin', matches: '10'),
      HistoryObject(query: 'island', matches: '44'),
      HistoryObject(query: 'demon', matches: '13'),
      HistoryObject(query: 'Myojin', matches: '10'),
      HistoryObject(query: 'island', matches: '44'),
      HistoryObject(query: 'demon', matches: '13'),
      HistoryObject(query: 'Myojin', matches: '10'),
      HistoryObject(query: 'island', matches: '44'),
    ];
  }

  //List<HistoryObject>
  Future<void> getDBData() async {
    List<HistoryObject> data = [];
    var historyData = await DBHelper.getHistoryData();
    print(historyData.toString());
    for (var historyElement in historyData) {
      data.add(
        HistoryObject(
          query: historyElement['searchText'].toString(),
          matches: historyElement['count'].toString(),
        ),
      );
    }
    _data = data;
    notifyListeners();
  }
}

class HistoryObject {
  String query;
  String matches;

  HistoryObject({required this.query, required this.matches});
}
