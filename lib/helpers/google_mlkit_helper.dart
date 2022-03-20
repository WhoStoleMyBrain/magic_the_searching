import 'dart:io';

import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class GoogleMlkitHelper {
  static final TextDetector textDetector = GoogleMlKit.vision.textDetector();
  static final LanguageIdentifier languageIdentifier =
      GoogleMlKit.nlp.languageIdentifier();

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
          GoogleMlkitHelper.languageIdentifier.errorCodeNoLanguageIdentified) {
        return '';
      }
      return '';
    }
  }

  static Future<String> getCardNameFromImage(File image) async {
    final inputImage = InputImage.fromFile(image);
    final RecognisedText recognisedText =
        await GoogleMlkitHelper.textDetector.processImage(inputImage);
    return recognisedText.blocks[0].lines[0].text;
  }
}
