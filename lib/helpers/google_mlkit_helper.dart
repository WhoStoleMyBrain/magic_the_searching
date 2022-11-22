import 'dart:io';

import 'package:flutter/services.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

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

  static Future<String> getCardNameFromImage(File image) async {
    final inputImage = InputImage.fromFile(image);
    final RecognizedText recognisedText =
        await GoogleMlkitHelper.textDetector.processImage(inputImage);
    // print(recognisedText.blocks);
    if (recognisedText.blocks.isEmpty) return '';
    return recognisedText.blocks[0].lines[0].text;
  }
}
