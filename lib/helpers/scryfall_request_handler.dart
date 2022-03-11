import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/card_data.dart';

class ScryfallRequestHandler {
  static const String apiBasePath = 'api.scryfall.com';
  static const String queryBaseString = '/cards/search';
  static const String versionBaseString = '/cards/search';
  static const String refreshBaseString = '/cards';
  static const String isshin =
      'https://c1.scryfall.com/file/scryfall-cards/large/front/a/0/a062a004-984e-4b62-960c-af7288f7a3e9.jpg?1643846546';
  static const String isshinLocal =
      'assets/images/isshin-two-heavens-as-one.jpg';
  String searchText;
  String query = '';
  Map<String, dynamic> responseData = {};
  ScryfallRequestHandler({required this.searchText});

  // void translateTextToQuery() {
  //   // query = searchText.replaceAll(RegExp(' '), '+');
  //   // query = Uri.encodeQueryComponent(searchText);
  //   query = Uri.https('', searchText).toString();
  //   query = 'q=' + query;
  //   // print(query);
  // }

  void getRequestHttpsQuery() {
    query = Uri.https(
            apiBasePath, queryBaseString, { 'q': searchText,})
        .toString();
  }

  void getRefreshPriceHttpsQuery() {
    query = Uri.https(
        apiBasePath, refreshBaseString, { '': searchText,})
        .toString();
  }

  void getVersionsHttpsQuery() {
    query = Uri.https(
        apiBasePath, versionBaseString, { 'unique':'art', 'q': searchText.contains(' ') ? '!"${searchText.substring(1)}"' : searchText})
        .toString();
  }

  void getPrintsHttpsQuery() {
    query = Uri.https(
        apiBasePath, versionBaseString, { 'unique':'prints', 'q': searchText.contains(' ') ? '!"${searchText.substring(1)}"' : searchText})
        .toString();
  }

  Future<void> sendQueryRequest() async {
    final url = Uri.parse(query);
    try {
      final response = await http.get(url);

      responseData = json.decode(response.body);
      if (response.statusCode != 200) {}
    } catch (error) {
      // print(error);
    }
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

  List<CardData> processQueryData() {
    final List<CardData> resultList = [];
    if (responseData["data"] != null) {
      responseData["data"].map(
        (result) {
          // print(result);
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
            ),
          );
        },
      ).toList();
    } else {}

    return resultList;
  }
}
