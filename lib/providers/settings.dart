import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/bulk_data_helper.dart';
import '../scryfall_api_json_serialization/bulk_data.dart';

class Settings with ChangeNotifier {
  bool _useLocalDB;
  bool _canUpdateDB;
  DateTime dbDate;
  bool _useImagesFromNet;

  Settings(
      this._useLocalDB, this._canUpdateDB, this.dbDate, this._useImagesFromNet);

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

  Future<void> checkCanUpdateDB() async {
    final prefs = await SharedPreferences.getInstance();
    DateTime oldDBDate = DateTime.parse(prefs.getString('dbUpdatedAt') ??
        DateTime.parse("1969-07-20 20:18:04Z").toIso8601String());
    BulkData? bulkData = await BulkDataHelper.getBulkData();
    if ((bulkData?.updatedAt
                .subtract(const Duration(days: 1))
                .isAfter(oldDBDate) ??
            true) &&
        (bulkData?.updatedAt != oldDBDate)) {
      canUpdateDB = true;
    } else {
      canUpdateDB = false;
    }
    dbDate = oldDBDate;
    notifyListeners();
  }

  Future<void> checkUseImagesFromNet() async {
    final prefs = await SharedPreferences.getInstance();
    bool useImages = prefs.getBool('useImagesFromNet') ?? true;
    useImagesFromNet = useImages;
  }
}
