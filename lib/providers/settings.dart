import 'package:flutter/material.dart';
import 'package:magic_the_searching/helpers/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/bulk_data_helper.dart';
import '../scryfall_api_json_serialization/bulk_data.dart';

class Settings with ChangeNotifier {
  bool _useLocalDB;
  bool _canUpdateDB;
  DateTime dbDate;
  bool _useImagesFromNet;
  Languages _language;

  Settings(this._useLocalDB, this._canUpdateDB, this.dbDate,
      this._useImagesFromNet, this._language);

  set useLocalDB(bool newValue) {
    _useLocalDB = newValue;
    notifyListeners();
  }

  bool get useLocalDB {
    return _useLocalDB;
  }

  set canUpdateDB(bool newValue) {
    _canUpdateDB = newValue;
    notifyListeners();
  }

  bool get canUpdateDB {
    return _canUpdateDB;
  }

  set useImagesFromNet(bool newValue) {
    _useImagesFromNet = newValue;
    notifyListeners();
  }

  bool get useImagesFromNet {
    return _useImagesFromNet;
  }

  Languages get language {
    return _language;
  }

  Future<void> checkCanUpdateDB() async {
    final prefs = await SharedPreferences.getInstance();
    DateTime oldDBDate = DateTime.parse(
        prefs.getString(Constants.settingDbUpdatedAt) ??
            Constants.defaultTimestamp);
    BulkData? bulkData = await BulkDataHelper.getBulkData();
    if ((bulkData?.updatedAt
                .subtract(const Duration(days: 1))
                .isAfter(oldDBDate) ??
            true) &&
        (bulkData?.updatedAt != oldDBDate)) {
      canUpdateDB = true;
    } else {
      canUpdateDB = true;
    }
    dbDate = oldDBDate;
    notifyListeners();
  }

  Future<void> checkUseImagesFromNet() async {
    final prefs = await SharedPreferences.getInstance();
    bool useImages = prefs.getBool(Constants.settingUseImagesFromNet) ?? true;
    useImagesFromNet = useImages;
  }

  Future<void> getUserLanguage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String userLanguageString =
        prefs.getString(Constants.settingUserLanguage) ?? 'en';
    final Languages userLanguage = Languages.values.byName(userLanguageString);
    _language = userLanguage;
  }

  Future<void> saveUserLanguage(Languages newLanguage) async {
    _language = newLanguage;
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(Constants.settingUserLanguage, _language.name);
    notifyListeners();
  }
}
