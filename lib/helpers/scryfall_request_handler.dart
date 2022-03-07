import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:magic_the_searching/providers/card_data_provider.dart';
import 'package:provider/provider.dart';

import '../models/card_data.dart';

class ScryfallRequestHandler {
  static const String apiBasePath = 'https://api.scryfall.com';
  static const String queryBaseString = '/cards/search?';
  static const String isshin = 'https://c1.scryfall.com/file/scryfall-cards/large/front/a/0/a062a004-984e-4b62-960c-af7288f7a3e9.jpg?1643846546';
  final String searchText;
  String query = '';
  Map<String, dynamic> responseData = {};
  ScryfallRequestHandler({required this.searchText});

  void translateTextToQuery() {
    query = searchText.replaceAll(RegExp(' '), '+');
    query = 'q=' + query;
  }

  Future<void> sendQueryRequest() async {
    final url = Uri.parse('$apiBasePath$queryBaseString$query');
    try {
      final response = await http.get(url);
      // print(response.statusCode);
      // print(response.headers);
      // print(response.body);
      responseData = json.decode(response.body);
    } catch (error) {
      print(error);
    }
  }

  String findPicture(Map<String, dynamic> card) {
    // print(card);
    // card.containsKey("card_faces") ? print(card["card_faces"]) : print('');
    return card.containsKey("image_uris")
        ? card["image_uris"]["normal"]
        : (card.containsKey("card_faces") ? (card["card_faces"][0].containsKey("image_uris") ? card["card_faces"][0]["image_uris"]["normal"] : isshin) : isshin);
  }

  List<CardData> processQueryData() {
    final List<CardData> resultList = [];
    // responseData["data"].forEach((key, value) {
    //   resultList.add(CardData(id: id, name: name, text: text, image: image))
    // });
    // print(responseData["data"]);
    // print(responseData["data"][0]["id"]);
    // print(responseData["data"]);
    final res = responseData["data"].map(
      (result) {
        // print(result);
        resultList.add(
          CardData(
            id: result["id"] ?? '',
            name: result["name"] ?? '',
            text: result["oracle_text"] ?? '',
            image: findPicture(result),
            // result.containsKey("image_uris")
            //     ? result["image_uris"]["small"]
            //     : isshin,
          ),
        );
      },
    ).toList();

    // print(res);
    // print(resultList);
    // CardDataProvider().cards = resultList;
    // return resultList;
    return resultList;
  }
}
