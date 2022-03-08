import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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