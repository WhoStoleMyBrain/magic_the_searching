import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../helpers/internet_usage_helper.dart';
import '../helpers/scryfall_request_handler.dart';
import '../helpers/db_helper.dart';
import '../scryfall_api_json_serialization/card_info.dart';

class CardDataProvider with ChangeNotifier {
  List<CardInfo> _cards = [];
  List<String> languages = [];
  String query = '';
  String column = 'searchText';
  bool isLoading = false;
  bool isStandardQuery = true;
  bool hasMore = false;
  Map<String, String> queryParameters = {};

  set cards(List<CardInfo> queryData) {
    _cards = queryData;
    isLoading = false;
    notifyListeners();
  }

  List<CardInfo> get cards {
    return [..._cards];
  }

  CardInfo getCardById(String id) {
    return cards.firstWhere((card) => card.id == id);
  }

  Future<bool> processQuery() async {
    isLoading = true;
    notifyListeners();
    return _requestDataFromScryfall();
  }

  Future<bool> processQueryLocally() async {
    isLoading = true;
    notifyListeners();
    List<Map<String, dynamic>> dbResult = await DBHelper.getCardsByName(query);
    if (dbResult.isEmpty) {
      cards = [];
      return false;
    } else {
      Map<String, dynamic> historyData = {
        'searchText': query,
        'matches': dbResult.length,
        'dateTime': DateTime.now().toIso8601String(),
      };
      DBHelper.insertIntoHistory(historyData);
    }
    cards = dbResult.map((e) => CardInfo.fromDB(e)).toList();
    return true;
  }

  Future<bool> _requestDataFromScryfall() async {
    final scryfallRequestHandler =
        ScryfallRequestHandler(searchText: query, languages: languages);
    scryfallRequestHandler.setHttpsQuery(queryParameters, isStandardQuery);
    await scryfallRequestHandler.sendQueryRequest();
    final queryResult = scryfallRequestHandler.processQueryData();
    if (queryResult.isEmpty) {
      cards = [];
      return false;
    } else {
      Map<String, dynamic> historyData = {
        'searchText': query,
        'matches': queryResult.length,
        'dateTime': DateTime.now().toIso8601String(),
      };
      DBHelper.insertIntoHistory(historyData);
    }
    cards = queryResult;
    return true;
  }
}
