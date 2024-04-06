import 'package:flutter/foundation.dart';
import 'package:magic_the_searching/enums/query_location.dart';
import 'package:magic_the_searching/helpers/constants.dart';

import '../helpers/scryfall_request_handler.dart';
import '../helpers/db_helper.dart';
import '../scryfall_api_json_serialization/card_info.dart';

class CardDataProvider with ChangeNotifier {
  List<CardInfo> _cards = [];
  List<Languages> languages = [];
  String query = '';
  bool isLoading = false;
  bool isStandardQuery = true;
  bool hasMore = false;
  QueryLocation _queryLocation = QueryLocation.none;
  Map<String, dynamic> scryfallQueryMaps = {};
  Map<String, dynamic> allQueryParameters = {};
  late ScryfallRequestHandler scryfallRequestHandler;

  set queryLocation(QueryLocation newQueryLocation) {
    _queryLocation = newQueryLocation;
    notifyListeners();
  }

  QueryLocation get queryLocation {
    return _queryLocation;
  }

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

    List<Map<String, dynamic>> dbResult =
        await DBHelper.getCardsByName(allQueryParameters);
    if (dbResult.isEmpty) {
      cards = [];
      Map<String, dynamic> historyData = {
        'searchText': query,
        'matches': dbResult.length,
        'dateTime': DateTime.now().toIso8601String(),
        'languages': languages.fold(
            '', (previousvalue, element) => '$previousvalue;${element.name}'),
      };
      DBHelper.insertIntoHistory(historyData);
      return false;
    } else {
      Map<String, dynamic> historyData = {
        'searchText': query,
        'matches': dbResult.length,
        'dateTime': DateTime.now().toIso8601String(),
        'languages': languages.fold(
            '', (previousvalue, element) => '$previousvalue;${element.name}'),
      };
      DBHelper.insertIntoHistory(historyData);
    }
    cards = dbResult.map((e) => CardInfo.fromDB(e)).toList();
    return true;
  }

  Future<bool> _requestDataFromScryfall() async {
    scryfallRequestHandler = ScryfallRequestHandler();
    scryfallRequestHandler.searchText = query;
    scryfallRequestHandler.setHttpsQuery(scryfallQueryMaps, isStandardQuery);
    await scryfallRequestHandler.sendQueryRequest();
    final queryResult = scryfallRequestHandler.processQueryData();
    if (kDebugMode) {
      print('queryResult: $queryResult');
    }
    if (queryResult.isEmpty) {
      cards = [];
      Map<String, dynamic> historyData = {
        'searchText': query,
        'matches': 0,
        'dateTime': DateTime.now().toIso8601String(),
        'languages': languages.fold(
            '', (previousvalue, element) => '$previousvalue;${element.name}'),
      };
      DBHelper.insertIntoHistory(historyData);
      return false;
    } else {
      hasMore = scryfallRequestHandler.responseData['has_more'];
      Map<String, dynamic> historyData = {
        'searchText': query,
        'matches':
            scryfallRequestHandler.responseData.containsKey("total_cards")
                ? scryfallRequestHandler.responseData["total_cards"]
                : 0, // queryResult.length,
        'dateTime': DateTime.now().toIso8601String(),
        'languages': languages.fold(
            '', (previousvalue, element) => '$previousvalue;${element.name}'),
      };
      DBHelper.insertIntoHistory(historyData);
      cards = queryResult;
    }
    return true;
  }

  Future<void> requestDataAtEndOfScroll() async {
    if (hasMore) {
      final List<CardInfo> response =
          await scryfallRequestHandler.getDataEndOfScroll().whenComplete(() {
        hasMore = scryfallRequestHandler.responseData['has_more'];
      });
      _cards.addAll(response);
      notifyListeners();
    }
  }
}
