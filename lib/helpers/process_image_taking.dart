import 'dart:io';

import 'package:flutter/material.dart';
import 'package:magic_the_searching/helpers/search_start_helper.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart' as sys_paths;

import 'google_mlkit_helper.dart';

class ProcessImageTaking {
  static final ProcessImageTaking _processImageTaking =
      ProcessImageTaking._internal();
  factory ProcessImageTaking() {
    return _processImageTaking;
  }
  ProcessImageTaking._internal();

  static Future<XFile?> takeImage() async {
    final picker = ImagePicker();
    final imageFile = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 200,
      maxHeight: 300,
      imageQuality: 25,
    );
    if (imageFile == null) {
      return null;
    }
    return imageFile;
  }

  static Future<File?> saveImage(XFile? imageFile) async {
    if (imageFile == null) {
      return null;
    }
    final appDir = await sys_paths.getApplicationDocumentsDirectory();
    final fileName = path.basename(imageFile.path);
    final savedImage =
        await File(imageFile.path).copy('${appDir.path}/$fileName');
    return savedImage;
  }

  static Future<void> takePictureAndFireQuery(BuildContext ctx) async {
    final imageFile = await ProcessImageTaking.takeImage();
    File file = File(imageFile?.path ?? '');
    if (await file.exists()) {
      // final savedImage = await ProcessImageTaking.saveImage(imageFile);
      // if (savedImage == null) {
      //   return;
      // }
      // final recognisedText =
      //     await GoogleMlkitHelper.getCardNameFromImage(savedImage);
      final recognisedText = await GoogleMlkitHelper.getCardNameFromImage(file);
      final cardLanguage =
          await GoogleMlkitHelper.getLanguageOfString(recognisedText);
      final List<String> languages =
          cardLanguage != 'en' ? ['en', cardLanguage] : ['en'];
      SearchStartHelper.startSearchForCard(ctx, recognisedText, languages);
    }
  }
}
