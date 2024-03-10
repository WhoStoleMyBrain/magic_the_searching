import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:magic_the_searching/helpers/constants.dart';
import 'package:magic_the_searching/models/mtg_set.dart';
import 'package:magic_the_searching/providers/scryfall_provider.dart';

import 'google_mlkit_helper.dart';
import 'search_start_helper.dart';

class ProcessImageTaking {
  static final ProcessImageTaking _processImageTaking =
      ProcessImageTaking._internal();
  factory ProcessImageTaking() {
    return _processImageTaking;
  }
  ProcessImageTaking._internal();

  static Future<File?> takeImage() async {
    Stopwatch stopwatch = Stopwatch()..start();
    final picker = ImagePicker();
    // picker.
    print('1: ${stopwatch.elapsed}');
    final imageFile = await picker.pickImage(
      requestFullMetadata: false,
      source: ImageSource.camera,
      imageQuality: 25,
    );
    print('2: ${stopwatch.elapsed}');
    if (imageFile == null) {
      return null;
    }
    print('3: ${stopwatch.elapsed}');
    return File(imageFile.path);
  }

  static Future<File?> cropImage({required File imageFile}) async {
    CroppedFile? croppedImage =
        await ImageCropper().cropImage(sourcePath: imageFile.path);
    if (croppedImage == null) return null;
    return File(croppedImage.path);
  }

  static Future<void> takePictureAndFireQuery(BuildContext ctx,
      {ScryfallProvider? scryfallProvider}) async {
    Stopwatch stopwatch = Stopwatch()..start();
    // final ScryfallProvider scryfallProvider =
    await ProcessImageTaking.takeImage().then((File? imageFile) async {
      if (imageFile == null) return;
      print('4: ${stopwatch.elapsed}');
      if (await imageFile.exists()) {
        print('5: ${stopwatch.elapsed}');
        await GoogleMlkitHelper.getCardNameFromImage(imageFile,
                scryfallProvider: scryfallProvider)
            .then((recognisedText) async {
          print('6: ${stopwatch.elapsed}');
          if (recognisedText[Constants.imageTextMapCardName] == '' ||
              recognisedText[Constants.imageTextMapCardName] == null) return;
          print('7: ${stopwatch.elapsed}');
          await GoogleMlkitHelper.getLanguageOfString(
                  recognisedText[Constants.imageTextMapCardName]!)
              .then((cardLanguage) {
            print('8: ${stopwatch.elapsed}');
            final List<String> languages =
                cardLanguage != 'en' ? ['en', cardLanguage] : ['en'];
            print('9: ${stopwatch.elapsed}');

            SearchStartHelper.startSearchForCard(
              ctx,
              recognisedText[Constants.imageTextMapCardName] ?? '',
              languages,
              recognisedText[Constants.imageTextMapCreatureType] ?? [],
              [],
              recognisedText[Constants.imageTextMapCardType] ?? [],
              MtGSet.empty(),
              '',
              '',
              {},
            );
          });
        });
      }
    });
    // .then((imageFile) async {
    //   return ProcessImageTaking.cropImage(imageFile: imageFile ?? File(''));
    // });
  }
}
