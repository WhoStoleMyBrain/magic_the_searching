// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:magic_the_searching/helpers/search_start_helper.dart';
// import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
// import 'package:path_provider/path_provider.dart' as sys_paths;

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
    // File file = File(imageFile.path);
    return File(imageFile.path);
  }

  static Future<File?> cropImage({required File imageFile}) async {
    CroppedFile? croppedImage =
        await ImageCropper().cropImage(sourcePath: imageFile.path);
    if (croppedImage == null) return null;
    return File(croppedImage.path);
  }

  // static Future<File?> saveImage(XFile? imageFile) async {
  //   if (imageFile == null) {
  //     return null;
  //   }
  //   final appDir = await sys_paths.getApplicationDocumentsDirectory();
  //   final fileName = path.basename(imageFile.path);
  //   final savedImage =
  //       await File(imageFile.path).copy('${appDir.path}/$fileName');
  //   return savedImage;
  // }

  static Future<void> takePictureAndFireQuery(BuildContext ctx) async {
    final file = await ProcessImageTaking.takeImage().then((imageFile) async {
      return ProcessImageTaking.cropImage(imageFile: imageFile ?? File(''));
    });
    // File file = File(imageFile?.path ?? '');
    // final file =
    //     await ProcessImageTaking.cropImage(imageFile: imageFile ?? File(''));
    if (file == null) return;
    if (await file.exists()) {
      // final savedImage = await ProcessImageTaking.saveImage(imageFile);
      // if (savedImage == null) {
      //   return;
      // }
      // final recognisedText =
      //     await GoogleMlkitHelper.getCardNameFromImage(savedImage);
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
