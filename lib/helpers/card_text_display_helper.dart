import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'card_symbol_helper.dart';
import 'constants.dart';

class CardTextDisplayHelper {
  static final CardTextDisplayHelper _cardTextDisplayHelper =
      CardTextDisplayHelper._internal();
  factory CardTextDisplayHelper() {
    return _cardTextDisplayHelper;
  }
  CardTextDisplayHelper._internal();

  static List<dynamic> textSpanWidgetsFromText(
      String text, Map<String, SvgPicture> symbolImages, double fontSize) {
    var loyaltyCostFinder = RegExp(r'[−+-]+\d+[:]|[{}]');
    List<String> splittedText = text.split(loyaltyCostFinder);
    var foundLoyalties =
        loyaltyCostFinder.allMatches(text).map((e) => e[0]!).toList();
    splittedText.removeWhere((element) {
      return element == '' || element == ' ';
    });
    foundLoyalties =
        foundLoyalties.map((e) => e == '{' || e == '}' ? '' : e).toList();
    var finalSplittedText = [];
    for (var element = 0; element < splittedText.length; element++) {
      if (element < foundLoyalties.length) {
        finalSplittedText.add(foundLoyalties[element]);
      }
      finalSplittedText.add(splittedText[element]);
    }
    List<dynamic> finalSpans = [];
    for (var textElement in finalSplittedText) {
      if (textElement.contains(Constants.placeholderSplitText)) {
        finalSpans.addAll([
          TextSpan(
              text: textElement.split(Constants.placeholderSplitText).first,
              style: TextStyle(fontSize: fontSize, color: Colors.black)),
          const WidgetSpan(
              child: Divider(
            endIndent: 20,
            indent: 20,
            color: Colors.black,
            thickness: 1,
          )),
          TextSpan(
              text: textElement.split(Constants.placeholderSplitText).last,
              style: TextStyle(fontSize: fontSize, color: Colors.black)),
        ]);
      } else if (!finalSpans.contains(Constants.placeholderSplitText)) {
        if (symbolImages.keys
            .contains(CardSymbolHelper.symbolToAssetPath(textElement))) {
          finalSpans.add(WidgetSpan(
            alignment: ui.PlaceholderAlignment.middle,
            child: SvgPicture.asset(
              CardSymbolHelper.symbolToAssetPath(textElement),
              height: fontSize,
              width: fontSize,
            ),
          ));
        } else if (loyaltyCostFinder.hasMatch(textElement)) {
          finalSpans.add(WidgetSpan(
              child: getLoyaltyDisplay(textElement, fontSize * 4 / 3)));
        } else {
          finalSpans.add(TextSpan(
              text: textElement,
              style: TextStyle(fontSize: fontSize, color: Colors.black)));
        }
      }
    }

    return finalSpans;
  }

  static Widget getLoyaltyDisplay(String? loyalty, double size) {
    return Stack(alignment: AlignmentDirectional.center, children: [
      SvgPicture.asset(
        Constants.loyaltyAssetPath,
        width: size,
        height: size,
      ),
      Text(
        loyalty ?? '0',
        style: const TextStyle(fontSize: 10, color: Colors.white),
      ),
    ]);
  }
}
