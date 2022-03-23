import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:magic_the_searching/helpers/scryfall_query_maps.dart';

import '../models/card_data.dart';

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

  List<String> getMultiplePictures(card) {
    List<String> images = [];
    card["card_faces"].forEach((cardFace) {
      images.add(cardFace["image_uris"]["normal"]);
    });
    return images;
  }

  List<String> findPictures(Map<String, dynamic> card) {
    return card.containsKey("image_uris")
        ? [card["image_uris"]["normal"]]
        : (card.containsKey("card_faces")
            ? (card["card_faces"][0].containsKey("image_uris")
                ? getMultiplePictures(card)
                : [isshinLocal, isshinLocal])
            : [isshinLocal, isshinLocal]);
  }

  Map<String, String> addPrices(Map<String, dynamic> card) {
    return card.containsKey('prices')
        ? {
            'tcg': card['prices'].containsKey('usd')
                ? (card['prices']['usd'] ?? ' --.--')
                : '',
            'tcg_foil': card['prices'].containsKey('usd_foil')
                ? (card['prices']['usd_foil'] ?? ' --.--')
                : '',
            'cardmarket': card['prices'].containsKey('eur')
                ? (card['prices']['eur'] ?? ' --.--')
                : '',
            'cardmarket_foil': card['prices'].containsKey('eur_foil')
                ? (card['prices']['eur_foil'] ?? ' --.--')
                : '',
          }
        : {
            'tcg': '--.--',
            'tcg_foil': '--.--',
            'cardmarket': '--.--',
            'cardmarket_foil': '--.--',
          };
  }

  Map<String, String> addLinks(Map<String, dynamic> card) {
    final Map<String, String> linksValues = {};
    if (card.containsKey('scryfall_uri')) {
      linksValues['scryfall'] = card['scryfall_uri'];
    } else {
      linksValues['scryfall'] = '';
    }
    if (card.containsKey('purchase_uris')) {
      if (card['purchase_uris'].containsKey('tcgplayer')) {
        linksValues['tcg'] = card['purchase_uris']['tcgplayer'];
      } else {
        linksValues['tcg'] = '';
      }
      if (card['purchase_uris'].containsKey('cardmarket')) {
        linksValues['cardmarket'] = card['purchase_uris']['cardmarket'];
      } else {
        linksValues['cardmarket'] = '';
      }
    } else {
      linksValues['tcg'] = '';
      linksValues['cardmarket'] = '';
    }
    return linksValues;
  }

  List<CardData> processQueryData() {
    final List<CardData> resultList = [];
    if (responseData["data"] != null) {
      responseData["data"].map(
        (result) {
          resultList.add(
            CardData(
              id: result["id"] ?? '',
              name: result["name"] ?? '',
              text: result["oracle_text"] ?? '',
              images: findPictures(result),
              hasTwoSides: (result.containsKey("card_faces") &&
                      !result.containsKey("image_uris"))
                  ? true
                  : false,
              price: addPrices(result),
              dateTime: DateTime.now(),
              links: addLinks(result),
            ),
          );
        },
      ).toList();
    } else {}

    return resultList;
  }
}
