import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:magic_the_searching/helpers/scryfall_query_maps.dart';

import '../models/card_data.dart';
import '../scryfall_api_json_serialization/card_info.dart';

class ScryfallRequestHandler {
  static const String apiBasePath = 'api.scryfall.com';
  static const String queryBaseString = '/cards/search';
  static const String isshin =
      'https://c1.scryfall.com/file/scryfall-cards/large/front/a/0/a062a004-984e-4b62-960c-af7288f7a3e9.jpg?1643846546';
  static const String isshinLocal =
      'assets/images/isshin-two-heavens-as-one.jpg';
  String searchText;
  String query = '';
  List<String> languages = [];
  Map<String, dynamic> responseData = {};
  ScryfallRequestHandler({required this.searchText, required this.languages});

  void _configureSearchTextToScryfall(bool isStandardQuery) {
    languages.removeWhere((element) => element == '');
    searchText = isStandardQuery
        ? languages.isEmpty
            ? searchText
            : languages.length > 1
                ? '(l:${languages.join(' or l:')}) $searchText'
                : 'l:${languages[0]} $searchText'
        : languages.isEmpty
            ? '!"$searchText"'
            : languages.length > 1
                ? '(l:${languages.join(' or l:')}) !"$searchText"'
                : 'l:${languages[0]} !"$searchText"';
    print(searchText);
  }

  void setHttpsQuery(Map<String, String> queryMap, bool isStandardQuery) {
    if (queryMap == ScryfallQueryMaps.languagesMap) {
      if (!languages.contains('any')) {
        languages.add('any');
      }
    } else {
      languages.removeWhere((element) => element == 'any');
    }
    _configureSearchTextToScryfall(isStandardQuery);
    queryMap['q'] = searchText;
    query = Uri.https(apiBasePath, queryBaseString, queryMap).toString();
    print(query);
    print(queryMap);
  }

  Future<void> sendQueryRequest() async {
    final url = Uri.parse(query);
    try {
      final response = await http.get(url);

      responseData = json.decode(response.body);
      if (response.statusCode != 200) {}
    } catch (error) {}
  }

  List<CardInfo> processQueryData() {
    final List<CardInfo> resultList = [];
    print(responseData["data"]);
    if (responseData["data"] != null) {
      for (Map<String, dynamic> item in responseData["data"]) {
        resultList.add(CardInfo.fromJson(item));
      }
    } else {}
    print(resultList);
    return resultList;
  }
}
