import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:magic_the_searching/providers/card_data_provider.dart';
import 'package:provider/provider.dart';

import '../models/card_data.dart';

class ScryfallRequestHandler {
  static const String apiBasePath = 'https://api.scryfall.com';
  static const String queryBaseString = '/cards/search?';
  static const String isshin =
      'https://c1.scryfall.com/file/scryfall-cards/large/front/a/0/a062a004-984e-4b62-960c-af7288f7a3e9.jpg?1643846546';
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
      if (response.statusCode != 200) {
        // print(response.statusCode);
        // print(response.headers);
        // throw HttpException('message');

      }
    } catch (error) {
      print(error);
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

                // card["card_faces"].forEach((cardFace) {
                //   return cardFace["image_uris"]["normal"];
                // })
                // ] // card["card_faces"][0]["image_uris"]["normal"]
                : [isshin])
            : [isshin]);
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
    // responseData["data"].forEach((key, value) {
    //   resultList.add(CardData(id: id, name: name, text: text, image: image))
    // });
    // print(responseData["data"]);
    // print(responseData["data"][0]["id"]);
    // print(responseData["data"]);
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
              hasTwoSides: result.containsKey("card_faces") ? true : false,
              price: addPrices(result),
            ),
          );
        },
      ).toList();
    } else {
      // print('reached alert dialog');
      // AlertDialog(
      //   content: Text(
      //       'The search for the following text was not successful: \n $searchText'),
      //   actions: [ElevatedButton(onPressed: () {}, child: Text('Okay'))],
      // );
    }

    // print(resultList);
    // CardDataProvider().cards = resultList;
    // return resultList;
    return resultList;
  }
}
