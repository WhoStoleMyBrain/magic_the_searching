import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:magic_the_searching/helpers/scryfall_query_maps.dart';

import '../helpers/scryfall_request_handler.dart';
import '../helpers/db_helper.dart';
import '../models/card_data.dart';

class CardDataProvider with ChangeNotifier {
  List<CardData> _cards = [];
  List<String> languages = [];
  String query = '';
  String column = 'searchText';
  bool isLoading = false;
  bool isStandardQuery = true;
  late Function dbHelperFunction;
  Map<String, String> queryParameters = {};

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

  Future<bool> processQuery() async {
    isLoading = true;
    var historyData = await dbHelperFunction();
    var queries = historyData.map((e) => e['searchText']);
    if (queries.contains(query)) {
      return _loadDataFromDB();
    } else {
      return _requestDataFromScryfall();
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
    scryfallRequestHandler.setHttpsQuery(queryParameters);
    await scryfallRequestHandler.sendQueryRequest();
    final queryResult = scryfallRequestHandler.processQueryData();
    if (queryResult.isEmpty) {
      cards = [];
      return false;
    } else {
      for (CardData card in queryResult) {
        await DBHelper.insert(
            'user_searches', card.toDB(card, query, !isStandardQuery));
      }
    }
    cards = queryResult;
    return true;
  }
}
