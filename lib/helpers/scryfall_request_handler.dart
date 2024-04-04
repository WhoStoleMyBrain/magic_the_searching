import 'dart:convert';

import 'package:http/http.dart' as http;
import '../helpers/constants.dart';
import '../scryfall_api_json_serialization/card_info.dart';

class ScryfallRequestHandler {
  static final ScryfallRequestHandler _scryfallRequestHandler =
      ScryfallRequestHandler._internal();
  factory ScryfallRequestHandler() {
    return _scryfallRequestHandler;
  }
  ScryfallRequestHandler._internal();

  static const String apiBasePath = 'api.scryfall.com';
  static const String queryBaseString = '/cards/search';
  String searchText = '';
  String query = '';
  List<Languages> languages = [];
  Map<String, dynamic> responseData = {};

  void _configureSearchTextToScryfall(bool isStandardQuery) {
    // languages.removeWhere((element) => element == '');
    searchText = searchText;
    // searchText = isStandardQuery
    //     ? languages.isEmpty
    //         ? searchText
    //         : languages.length > 1
    //             ? '(l:${languages.join(' or l:')}) $searchText'
    //             : 'l:${languages[0]} $searchText'
    //     : languages.isEmpty
    //         ? '!"$searchText"'
    //         : languages.length > 1
    //             ? '(l:${languages.join(' or l:')}) !"$searchText"'
    //             : 'l:${languages[0]} !"$searchText"';
  }

  void setHttpsQuery(Map<String, dynamic> queryMap, bool isStandardQuery) {
    //TODO: Add any language to query
    _configureSearchTextToScryfall(isStandardQuery);
    queryMap['q'] = searchText;
    query = Uri.https(apiBasePath, queryBaseString, queryMap).toString();
  }

  Future<void> sendQueryRequest() async {
    // print('sending query request: $query');
    final url = Uri.parse(query);
    try {
      final response = await http.get(url);
      if (response.statusCode != 200) {
        responseData.clear();
        return;
      }
      responseData = json.decode(response.body);
    } catch (error) {
      return;
    }
  }

  List<CardInfo> processQueryData() {
    final List<CardInfo> resultList = [];
    if (responseData["data"] != null) {
      for (Map<String, dynamic> item in responseData["data"]) {
        resultList.add(CardInfo.fromJson(item));
      }
    }
    return resultList;
  }

  Future<List<CardInfo>> getDataEndOfScroll() async {
    final String? uriNextPage = responseData['next_page'];
    final url = Uri.parse(uriNextPage ?? '');
    try {
      final response = await http.get(url);
      if (response.statusCode != 200) {
        return [];
      }
      responseData = json.decode(response.body);
    } catch (error) {
      return [];
    }
    final List<CardInfo> resultList = [];
    if (responseData["data"] != null) {
      for (Map<String, dynamic> item in responseData["data"]) {
        resultList.add(CardInfo.fromJson(item));
      }
    }
    return resultList;
  }
}
