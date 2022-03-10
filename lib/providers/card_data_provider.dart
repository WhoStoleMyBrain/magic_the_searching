import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../helpers/scryfall_request_handler.dart';
import '../helpers/db_helper.dart';
import '../models/card_data.dart';

class CardDataProvider with ChangeNotifier {
  List<CardData> _cards = [];
  String query = '';
  String column = 'searchText';

  List<CardData> get cards {
    return [..._cards];
  }

  set cards(List<CardData> queryData) {
    _cards = queryData;
    notifyListeners();
  }

  CardData getCardById(String id) {
    return _cards.firstWhere((card) => card.id == id);
  }

  Future<bool> processSearchQuery() async {
    var historyData = await DBHelper.getHistoryData();
    var queries = historyData.map((e) => e['searchText']);
    if (queries.contains(query)) {
      // print('loading from DB');
      return _loadDataFromDB();
    } else {
      // print('loading from scryfall');
      return _requestDataFromScryfall();
    }
  }

  Future<bool> processVersionsQuery() async {
    var historyData = await DBHelper.getVersionsData();
    var queries = historyData.map((e) => e['searchText']);
    // print(queries);
    if (queries.contains(query) && queries.length > 1) {
      // if (false) {
      // print('loading from DB');
      return _loadDataFromDB();
    } else {
      // print('loading from scryfall');
      return _requestVersionsFromScryfall();
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
    // var dbData = await DBHelper.getData('user_searches', searchText);
    // print(dbData);
    List<CardData> myData = [];
    // print(dbData['user_searches']?[0]);
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
    // print(myData[0].name);
    cards = myData;
    return true;
  }

  Future<bool> _requestDataFromScryfall() async {
    final scryfallRequestHandler = ScryfallRequestHandler(searchText: query);
    // scryfallRequestHandler.translateTextToQuery();
    scryfallRequestHandler.getRequestHttpsQuery();
    await scryfallRequestHandler.sendQueryRequest();
    final queryResult = scryfallRequestHandler.processQueryData();
    if (queryResult.isEmpty) {
      return false;
    } else {
      for (CardData card in queryResult) {
        await DBHelper.insert('user_searches', card.toDB(card, query, false));
        // print('${card.name} inserted to DB');
      }
    }
    cards = queryResult;
    return true;
  }

  Future<bool> _requestVersionsFromScryfall() async {
    final scryfallRequestHandler = ScryfallRequestHandler(searchText: query);
    // scryfallRequestHandler.translateTextToQuery();
    scryfallRequestHandler.getVersionsHttpsQuery();
    await scryfallRequestHandler.sendVersionsRequest();
    final queryResult = scryfallRequestHandler.processQueryData();
    // print(queryResult);
    if (queryResult.isEmpty) {
      return false;
    } else {
      for (CardData card in queryResult) {
        await DBHelper.insert('user_searches', card.toDB(card, query, true));
        // print('${card.name} inserted to DB');
      }
    }
    cards = queryResult;
    // print(queryResult.length);

    return true;
  }

  //sendVersionsRequest(String cardName)
}
