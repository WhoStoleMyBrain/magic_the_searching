import 'package:flutter/cupertino.dart';

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
}

class HistoryObject {
  String query;
  String matches;

  HistoryObject({required this.query, required this.matches});
}
