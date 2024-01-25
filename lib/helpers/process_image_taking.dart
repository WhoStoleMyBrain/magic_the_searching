import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'google_mlkit_helper.dart';

class ProcessImageTaking {
  static final ProcessImageTaking _processImageTaking =
      ProcessImageTaking._internal();
  factory ProcessImageTaking() {
    return _processImageTaking;
  }
  ProcessImageTaking._internal();

  static Future<File?> takeImage() async {
    final picker = ImagePicker();
    final imageFile = await picker.pickImage(
      requestFullMetadata: false,
      source: ImageSource.camera,
      // maxWidth: 800,
      // maxHeight: 1200,
      imageQuality: 25,
    );

    if (imageFile == null) {
      return null;
    }
    return File(imageFile.path);
  }

  static Future<File?> cropImage({required File imageFile}) async {
    CroppedFile? croppedImage =
        await ImageCropper().cropImage(sourcePath: imageFile.path);
    if (croppedImage == null) return null;
    return File(croppedImage.path);
  }

  static Future<void> takePictureAndFireQuery(BuildContext ctx) async {
    final file = await ProcessImageTaking.takeImage().then((imageFile) async {
      return ProcessImageTaking.cropImage(imageFile: imageFile ?? File(''));
    });
    if (file == null) return;
    if (await file.exists()) {
      final recognisedText = await GoogleMlkitHelper.getCardNameFromImage(file);
      if (recognisedText == '') return;
      final cardLanguage =
          await GoogleMlkitHelper.getLanguageOfString(recognisedText);
      final List<String> languages =
          cardLanguage != 'en' ? ['en', cardLanguage] : ['en'];
      //TODO Fix this code!!
      // SearchStartHelper.startSearchForCard(ctx, recognisedText, languages);
    }
  }
}
