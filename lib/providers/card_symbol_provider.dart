import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CardSymbolProvider with ChangeNotifier {
  final Map<String, SvgPicture> _symbolImages = {};

  Future<void> getAllAssetImages() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');

    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    final imagePaths = manifestMap.keys
        .where((String key) => key.contains('images/'))
        .where((String key) => key.contains('.svg'))
        .toList();
    for (var path in imagePaths) {
      _symbolImages.addAll({path: _getCardSymbolPicture(path)});
    }
  }

  SvgPicture _getCardSymbolPicture(String cardSymbol) {
    return SvgPicture.asset(
      cardSymbol,
      alignment: Alignment.center,
      fit: BoxFit.cover,
      height: 20,
      width: 20,
    );
  }

  SvgPicture? getSymbolImage(String cardSymbol) {
    var tmp = _symbolImages[cardSymbol];
    return tmp;
  }

  Map<String, SvgPicture> get symbolImages {
    return _symbolImages;
  }
}
