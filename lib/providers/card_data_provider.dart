import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../helpers/database_loader.dart';
import '../helpers/internet_usage_helper.dart';
import '../helpers/scryfall_request_handler.dart';
import '../helpers/db_helper.dart';
import '../models/card_data.dart';
import '../scryfall_api_json_serialization/card_info.dart';

class CardDataProvider with ChangeNotifier {
  // List<CardData> _cards = [];
  List<CardInfo> _cards = [];
  List<String> languages = [];
  String query = '';
  String column = 'searchText';
  bool isLoading = false;
  bool isStandardQuery = true;
  late Function dbHelperFunction;
  Map<String, String> queryParameters = {};

  // List<CardData> get cards {
  //   return [..._cards];
  // }

  set cards(List<CardInfo> queryData) {
    _cards = queryData;
    isLoading = false;
    notifyListeners();
  }

  List<CardInfo> get cards {
    return [..._cards];
  }

  // set cards(List<CardData> queryData) {
  //   _cards = queryData;
  //   isLoading = false;
  //   notifyListeners();
  // }

  CardInfo getCardById(String id) {
    return cards.firstWhere((card) => card.id == id);
  }

  Future<bool> processQuery() async {
    isLoading = true;
    var historyData = await dbHelperFunction();
    var queries = historyData.map((e) => e['searchText']);
    if (queries.contains(query) && false) {
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
    List<CardInfo> myData = [];
    for (int i = 0; i < dbData['user_searches']!.length; i++) {
      myData.add(CardInfo.fromJson(dbData));
      // CardData.fromMap(
      //   {
      //     'user_searches': dbData['user_searches']?[i] ?? {},
      //     'search_images': dbData['search_images']?[i] ?? {},
      //     'search_prices': dbData['search_prices']?[i] ?? {},
      //   },
      // ),
      // );
    }
    cards = myData;
    return true;
  }

  Future<void> internetUsage() async {
    final internetUsageStats = InternetUsageHelper();
    internetUsageStats.endDate = DateTime.now();
    await internetUsageStats.updateInternetUsage();
    const myPackageName = 'com.example.magic_the_searching';
    print(DateTime.now());

    final networkInfos = await internetUsageStats.networkInfos;
    final double newBytesReceived = double.parse(networkInfos
            .firstWhere((element) => element.packageName == myPackageName)
            .rxTotalBytes ??
        '');
    final double newBytesTransferred = double.parse(networkInfos
            .firstWhere((element) => element.packageName == myPackageName)
            .txTotalBytes ??
        '');
    print('newMB-R: ${(newBytesReceived / 1024 / 1024).toStringAsFixed(0)}, '
        'oldMB-R: ${(internetUsageStats.startBytesReceived / 1024 / 1024).toStringAsFixed(0)}, '
        'difference: ${((newBytesReceived - internetUsageStats.startBytesReceived) / 1024 / 1024).toStringAsFixed(0)}');
    print('newMB-T: ${(newBytesTransferred / 1024 / 1024).toStringAsFixed(0)}, '
        'oldMB-T: ${(internetUsageStats.startBytesTransferred / 1024 / 1024).toStringAsFixed(0)}, '
        'difference: ${((newBytesTransferred - internetUsageStats.startBytesTransferred) / 1024 / 1024).toStringAsFixed(0)}');
  }

  Future<bool> _requestDataFromScryfall() async {
    final scryfallRequestHandler =
        ScryfallRequestHandler(searchText: query, languages: languages);
    scryfallRequestHandler.setHttpsQuery(queryParameters, isStandardQuery);
    await scryfallRequestHandler.sendQueryRequest();
    final queryResult = scryfallRequestHandler.processQueryData();
    if (queryResult.isEmpty) {
      print('request not successful');
      cards = [];
      return false;
    } else {
      for (CardInfo card in queryResult) {
        // await DBHelper.insert(
        // 'user_searches', card.toDB(card, query, !isStandardQuery));
        // 'user_searches', card.toJson();
      }
    }
    cards = queryResult;
    internetUsage();
    return true;
  }

  Future<void> loadDataFromLocalDB() async {
    final List dataBaseList = await DatabaseLoader.readDataFromDBFile(
        DatabaseLoader.cardDatabasePath);
    cards = dataBaseList.map((e) {
      return CardInfo.fromJson(e);
    }).toList();
    query = 'testQuery';
    notifyListeners();
    // print(cards2[0].prices?.toJson());
  }
}
