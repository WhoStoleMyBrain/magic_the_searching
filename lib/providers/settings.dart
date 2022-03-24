import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/bulk_data_helper.dart';
import '../scryfall_api_json_serialization/bulk_data.dart';

class Settings with ChangeNotifier {
  bool _useLocalDB;
  bool _canUpdateDB;
  DateTime dbDate;

  Settings(this._useLocalDB, this._canUpdateDB, this.dbDate);

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

  Future<void> checkCanUpdateDB() async {
    final prefs = await SharedPreferences.getInstance();
    var dt = prefs.getString('dbUpdatedAt');
    print(dt);
    DateTime oldDBDate = DateTime.parse(
        prefs.getString('dbUpdatedAt') ?? DateTime.now().toIso8601String());
    BulkData? bulkData = await BulkDataHelper.getBulkData();
    if (bulkData?.updatedAt
            .subtract(const Duration(days: 0))
            .isAfter(oldDBDate) ??
        true) {
      canUpdateDB = true;
    } else {
      canUpdateDB = true;
    }
    dbDate = oldDBDate;
    print('can Update: $canUpdateDB');
    print('Old db Date: $oldDBDate');
    notifyListeners();
  }
}
