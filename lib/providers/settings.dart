import 'package:flutter/material.dart';

class Settings with ChangeNotifier {

  bool _useLocalDB;

  Settings(this._useLocalDB);

  set useLocalDB(bool newValue) {
    _useLocalDB = newValue;
    notifyListeners();
  }

  bool get useLocalDB {
    return _useLocalDB;
  }

}