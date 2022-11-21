import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CardSymbolHelper {
  static final CardSymbolHelper _cardSymbolHelper =
      CardSymbolHelper._internal();

  factory CardSymbolHelper() {
    return _cardSymbolHelper;
  }

  CardSymbolHelper._internal();

  static Future<Widget> getSymbolFromText(String text) async {
    String shortText = text.replaceAll("{", "");
    shortText = shortText.replaceAll("}", "");
    shortText = shortText.replaceAll("/", "-");
    String symbolPath = "assets/images/$shortText.svg";
    Widget assetImage = Image.asset(
      symbolPath,
      errorBuilder: (context, error, stackTrace) {
        return Text(text);
      },
    );
    return assetImage;
  }

  static List<String> getSymbolsOfText(String text) {
    List<String> splitted = text.split('{');
    // if (kDebugMode) print(splitted);
    Iterable<String> manaCosts = splitted.map((e) => e.split('}').first);
    manaCosts = manaCosts.skip(1);
    manaCosts = manaCosts.map((e) => symbolToAssetPath(e));
    return manaCosts.toList();
  }

  static String symbolToAssetPath(String symbol) {
    return 'assets/images/$symbol.svg';
  }

  static Future<List<String>> listAssetImages() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');

    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    // >> To get paths you need these 2 lines

    final imagePaths = manifestMap.keys
        .where((String key) => key.contains('images/'))
        .where((String key) => key.contains('.svg'))
        .toList();
    // print(imagePaths);
    return imagePaths;
  }
}
