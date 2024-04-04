import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:magic_the_searching/helpers/constants.dart';
import 'package:magic_the_searching/providers/scryfall_provider.dart';

class GoogleMlkitHelper {
  static final GoogleMlkitHelper _googleMlkitHelper =
      GoogleMlkitHelper._internal();
  factory GoogleMlkitHelper() {
    return _googleMlkitHelper;
  }
  GoogleMlkitHelper._internal();

  static final textDetector =
      TextRecognizer(script: TextRecognitionScript.latin);
  static final LanguageIdentifier languageIdentifier =
      LanguageIdentifier(confidenceThreshold: 0.5);

  void dispose() async {
    await textDetector.close();
    await languageIdentifier.close();
  }

  static Future<String> getLanguageOfString(String message) async {
    try {
      final String response =
          await GoogleMlkitHelper.languageIdentifier.identifyLanguage(message);
      return response;
    } on PlatformException catch (pe) {
      if (pe.code ==
          GoogleMlkitHelper.languageIdentifier.undeterminedLanguageCode) {
        return '';
      }
      return '';
    }
  }

  static Future<Map<String, dynamic>> getCardNameFromXfile(XFile image,
      {ScryfallProvider? scryfallProvider}) async {
    List<String> cardType = [];
    List<String> creatureType = [];
    List<String> languages = [];
    final InputImage inputImage = InputImage.fromFilePath(image.path);
    final RecognizedText recognisedText =
        await GoogleMlkitHelper.textDetector.processImage(inputImage);
    Map<String, dynamic> returnMap = {};
    if (recognisedText.blocks.isEmpty) return returnMap;
    final cardName = _getCardNameFromBlocks(recognisedText.blocks);
    if (scryfallProvider != null) {
      cardType =
          _getCardTypeFromBlocks(recognisedText.blocks, scryfallProvider);
      creatureType =
          _getCreatureTypeFromBlocks(recognisedText.blocks, scryfallProvider);
    } else {
      if (kDebugMode) {
        print(
            'not getting card type and creature type, since there is no scryfall provider');
      }
    }
    languages.add(await getLanguageOfString(cardName));
    for (String cardTyp in cardType) {
      languages.add(await getLanguageOfString(cardTyp));
    }
    for (String creatureTyp in creatureType) {
      languages.add(await getLanguageOfString(creatureTyp));
    }
    languages = languages.toSet().toList();
    languages.removeWhere((element) => element == "und");
    List<Languages> scryfallLanguages = languages
        .map((e) => Languages.values.firstWhere(
              (element) => element.googleMlKitId == e,
              orElse: () => Languages.en,
            ))
        .toList();
    returnMap[Constants.imageTextMapCardName] = cardName;
    returnMap[Constants.imageTextMapCardType] = cardType;
    returnMap[Constants.imageTextMapCreatureType] = creatureType;
    returnMap[Constants.imageTextMapLanguages] = scryfallLanguages;
    return returnMap;
  }

  static _getCardNameFromBlocks(List<TextBlock> blocks) {
    return blocks[0].lines[0].text;
  }

  static List<String> _getCardTypeFromBlocks(
      List<TextBlock> blocks, ScryfallProvider scryfallProvider) {
    final regexpString = scryfallProvider.cardTypes
        .reduce((value, element) => '$value|$element');
    return _matchStringToTextBlock(blocks[1], regexpString);
  }

  static List<String> _getCreatureTypeFromBlocks(
      List<TextBlock> blocks, ScryfallProvider scryfallProvider) {
    final regexpString = scryfallProvider.creatureTypes
        .reduce((value, element) => '$value|$element');
    return _matchStringToTextBlock(blocks[1], regexpString);
  }

  static List<String> _matchStringToTextBlock(
      TextBlock textBlock, String regExpString) {
    final RegExp regExp = RegExp(regExpString);
    if (regExp.hasMatch(textBlock.lines[0].text)) {
      var allMatches = regExp.allMatches(textBlock.lines[0].text);
      for (var m in allMatches) {
        String match = m[0]!;
        if (kDebugMode) {
          print(match);
        }
        // return match;
      }
      return allMatches.map<String>((e) => e[0]!).toList();
    } else {
      if (kDebugMode) {
        print(
            'No matches in textBlock ${textBlock.lines[0].text} with regExp: $regExpString');
      }
    }
    return [];
  }
}
