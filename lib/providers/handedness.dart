import 'package:flutter/material.dart';

class Handedness with ChangeNotifier {
  bool _handedness;

  Handedness(this._handedness);

  set handedness(bool newValue) {
    _handedness = newValue;
    notifyListeners();
  }

  bool get handedness {
    return _handedness;
  }
}