import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../helpers/scryfall_request_handler.dart';
import '../helpers/db_helper.dart';
import '../models/card_data.dart';

class CardDataProvider with ChangeNotifier {
  List<CardData> _cards = [];
  List<String> languages = [];
  String query = '';
  String column = 'searchText';
  bool isLoading = false;

  List<CardData> get cards {
    return [..._cards];
  }

  set cards(List<CardData> queryData) {
    _cards = queryData;
    isLoading = false;
    notifyListeners();
  }

  CardData getCardById(String id) {
    return cards.firstWhere((card) => card.id == id);
  }

  Future<bool> processSearchQuery() async {
    isLoading = true;
    var historyData = await DBHelper.getHistoryData();
    var queries = historyData.map((e) => e['searchText']);
    if (queries.contains(query)) {
      return _loadDataFromDB();
    } else {
      return _requestDataFromScryfall();
    }
  }

  Future<bool> processLanguagesQuery() async {
    print(query);
    isLoading = true;
    var historyData = await DBHelper.getHistoryData();
    var queries = historyData.map((e) => e['searchText']);
    if (queries.contains(query) && false) {
      return _loadDataFromDB();
    } else {
      return _requestLanguagesFromScryfall();
    }
  }

  Future<bool> processVersionsQuery() async {
    isLoading = true;
    var historyData = await DBHelper.getVersionsOrPrintsData();
    var queries = historyData.map((e) => e['searchText']);
    if (queries.contains(query) && queries.length > 1) {
      return _loadDataFromDB();
    } else {
      return _requestVersionsFromScryfall();
    }
  }

  Future<bool> processPrintsQuery() async {
    isLoading = true;
    var historyData = await DBHelper.getVersionsOrPrintsData();
    var queries = historyData.map((e) => e['searchText']);
    if (queries.contains(query) && queries.length > 1) {
      return _loadDataFromDB();
    } else {
      return _requestPrintsFromScryfall();
    }
  }

  Future<bool> _loadDataFromDB() async {
    var dbData = {
      'user_searches':
          await DBHelper.getData('user_searches', 'searchText', query),
      'search_images':
          await DBHelper.getData('search_images', 'searchText', query),
      'search_prices':
          await DBHelper.getData('search_prices', 'searchText', query),
    };
    List<CardData> myData = [];
    for (int i = 0; i < dbData['user_searches']!.length; i++) {
      myData.add(
        CardData.fromMap(
          {
            'user_searches': dbData['user_searches']?[i] ?? {},
            'search_images': dbData['search_images']?[i] ?? {},
            'search_prices': dbData['search_prices']?[i] ?? {},
          },
        ),
      );
    }
    cards = myData;
    return true;
  }

  Future<bool> _requestDataFromScryfall() async {
    final scryfallRequestHandler =
        ScryfallRequestHandler(searchText: query, languages: languages);
    scryfallRequestHandler.getRequestHttpsQuery();
    await scryfallRequestHandler.sendQueryRequest();
    final queryResult = scryfallRequestHandler.processQueryData();
    if (queryResult.isEmpty) {
      cards = [];
      return false;
    } else {
      for (CardData card in queryResult) {
        await DBHelper.insert('user_searches', card.toDB(card, query, false));
      }
    }
    cards = queryResult;
    return true;
  }

  Future<bool> _requestVersionsFromScryfall() async {
    final scryfallRequestHandler =
        ScryfallRequestHandler(searchText: query, languages: languages);
    print(scryfallRequestHandler.query);
    scryfallRequestHandler.getVersionsHttpsQuery();
    await scryfallRequestHandler.sendQueryRequest();
    final queryResult = scryfallRequestHandler.processQueryData();
    if (queryResult.isEmpty) {
      cards = [];
      return false;
    } else {
      for (CardData card in queryResult) {
        await DBHelper.insert('user_searches', card.toDB(card, query, true));
      }
    }
    cards = queryResult;
    return true;
  }

  Future<bool> _requestLanguagesFromScryfall() async {
    final scryfallRequestHandler =
        ScryfallRequestHandler(searchText: query, languages: languages);
    scryfallRequestHandler.getLanguagesHttpsQuery();
    await scryfallRequestHandler.sendQueryRequest();
    final queryResult = scryfallRequestHandler.processQueryData();
    if (queryResult.isEmpty) {
      cards = [];
      return false;
    } else {
      for (CardData card in queryResult) {
        await DBHelper.insert('user_searches', card.toDB(card, query, true));
      }
    }
    cards = queryResult;
    return true;
  }

  Future<bool> _requestPrintsFromScryfall() async {
    final scryfallRequestHandler =
        ScryfallRequestHandler(searchText: query, languages: languages);
    scryfallRequestHandler.getPrintsHttpsQuery();
    await scryfallRequestHandler.sendQueryRequest();
    final queryResult = scryfallRequestHandler.processQueryData();
    if (queryResult.isEmpty) {
      cards = [];
      return false;
    } else {
      for (CardData card in queryResult) {
        await DBHelper.insert('user_searches', card.toDB(card, query, true));
      }
    }
    cards = queryResult;
    return true;
  }
}
