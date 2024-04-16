import 'package:flutter/material.dart';
import 'package:magic_the_searching/helpers/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ColorProvider with ChangeNotifier {
  void init() async {
    sharedPreferences = await SharedPreferences.getInstance();
    int? backgroundColor1Int =
        sharedPreferences.getInt(Constants.settingsBackgroundColor1Name) ??
            _defaultBackgroundColor1.value;
    backgroundColor1 = Color(backgroundColor1Int);
    int? backgroundColor2Int =
        sharedPreferences.getInt(Constants.settingsBackgroundColor2Name) ??
            _defaultBackgroundColor2.value;
    backgroundColor2 = Color(backgroundColor2Int);
    int? appDrawerColor1Int =
        sharedPreferences.getInt(Constants.settingsAppDrawer1ColorName) ??
            _defaultAppdrawerColor1.value;
    appDrawerColor1 = Color(appDrawerColor1Int);
    int? appDrawerColor2Int =
        sharedPreferences.getInt(Constants.settingsAppDrawer2ColorName) ??
            _defaultAppdrawerColor2.value;
    appDrawerColor2 = Color(appDrawerColor2Int);
    int? mainScreenColor1Int =
        sharedPreferences.getInt(Constants.settingsMainScreen1ColorName) ??
            _defaultMainScreenColor1.value;
    mainScreenColor1 = Color(mainScreenColor1Int);
    int? mainScreenColor2Int =
        sharedPreferences.getInt(Constants.settingsMainScreen2ColorName) ??
            _defaultMainScreenColor2.value;
    mainScreenColor2 = Color(mainScreenColor2Int);
    int? mainScreenColor3Int =
        sharedPreferences.getInt(Constants.settingsMainScreen3ColorName) ??
            _defaultMainScreenColor3.value;
    mainScreenColor3 = Color(mainScreenColor3Int);
    int? mainScreenColor4Int =
        sharedPreferences.getInt(Constants.settingsMainScreen4ColorName) ??
            _defaultMainScreenColor4.value;
    mainScreenColor4 = Color(mainScreenColor4Int);
  }

  final Color _defaultBackgroundColor1 =
      const Color.fromRGBO(199, 195, 205, 1.0);
  final Color _defaultBackgroundColor2 =
      const Color.fromRGBO(218, 229, 223, 1.0);
  final Color _defaultAppdrawerColor1 =
      const Color.fromRGBO(199, 195, 205, 1.0);
  final Color _defaultAppdrawerColor2 =
      const Color.fromRGBO(218, 229, 223, 1.0);
  final Color _defaultMainScreenColor1 =
      const Color.fromRGBO(243, 187, 180, 1.0);
  final Color _defaultMainScreenColor2 =
      const Color.fromRGBO(172, 121, 143, 1.0);
  final Color _defaultMainScreenColor3 = const Color.fromRGBO(71, 86, 138, 1.0);
  final Color _defaultMainScreenColor4 = const Color.fromRGBO(20, 64, 101, 1.0);

  final Color defaultBackgroundColorDarkMode1 =
      const Color.fromRGBO(13, 13, 13, 1.0);
  final Color defaultBackgroundColorDarkMode2 =
      const Color.fromRGBO(48, 48, 48, 1.0);
  final Color defaultAppdrawerColorDarkMode1 =
      const Color.fromRGBO(13, 13, 13, 1.0);
  final Color defaultAppdrawerColorDarkMode2 =
      const Color.fromRGBO(48, 48, 48, 1.0);
  final Color defaultMainScreenColorDarkMode1 =
      const Color.fromRGBO(26, 26, 26, 1.0);
  final Color defaultMainScreenColorDarkMode2 =
      const Color.fromRGBO(44, 44, 44, 1.0);
  final Color defaultMainScreenColorDarkMode3 =
      const Color.fromRGBO(67, 67, 67, 1.0);
  final Color defaultMainScreenColorDarkMode4 =
      const Color.fromRGBO(92, 92, 92, 1.0);
  // the following is not dark mode, its rather flashy and more like tron
  final Color defaultBackgroundColorTronMode1 =
      const Color.fromRGBO(0, 255, 255, 1.0);
  final Color defaultBackgroundColorTronMode2 =
      const Color.fromRGBO(255, 0, 166, 1.0);
  final Color defaultAppdrawerColorTronMode1 =
      const Color.fromRGBO(0, 255, 255, 1.0);
  final Color defaultAppdrawerColorTronMode2 =
      const Color.fromRGBO(255, 0, 166, 1.0);
  final Color defaultMainScreenColorTronMode1 =
      const Color.fromRGBO(12, 113, 195, 1.0);
  final Color defaultMainScreenColorTronMode2 =
      const Color.fromRGBO(0, 255, 209, 1.0);
  final Color defaultMainScreenColorTronMode3 =
      const Color.fromRGBO(255, 0, 185, 1.0);
  final Color defaultMainScreenColorTronMode4 =
      const Color.fromRGBO(85, 0, 255, 1.0);

  late SharedPreferences sharedPreferences;

  late Color _backgroundColor1 = _defaultBackgroundColor1;
  late Color _backgroundColor2 = _defaultBackgroundColor2;
  late Color _appDrawerColor1 = _defaultAppdrawerColor1;
  late Color _appDrawerColor2 = _defaultAppdrawerColor2;
  late Color _mainScreenColor1 = _defaultMainScreenColor1;
  late Color _mainScreenColor2 = _defaultMainScreenColor2;
  late Color _mainScreenColor3 = _defaultMainScreenColor3;
  late Color _mainScreenColor4 = _defaultMainScreenColor4;

  Color get backgroundColor1 {
    return _backgroundColor1;
  }

  Color get backgroundColor2 {
    return _backgroundColor2;
  }

  Color get appDrawerColor1 {
    return _appDrawerColor1;
  }

  Color get appDrawerColor2 {
    return _appDrawerColor2;
  }

  Color get mainScreenColor1 {
    return _mainScreenColor1;
  }

  Color get mainScreenColor2 {
    return _mainScreenColor2;
  }

  Color get mainScreenColor3 {
    return _mainScreenColor3;
  }

  Color get mainScreenColor4 {
    return _mainScreenColor4;
  }

  set backgroundColor1(Color newColor) {
    sharedPreferences.setInt(
        Constants.settingsBackgroundColor1Name, newColor.value);
    _backgroundColor1 = newColor;
    notifyListeners();
  }

  set backgroundColor2(Color newColor) {
    sharedPreferences.setInt(
        Constants.settingsBackgroundColor2Name, newColor.value);
    _backgroundColor2 = newColor;
    notifyListeners();
  }

  set appDrawerColor1(Color newColor) {
    sharedPreferences.setInt(
        Constants.settingsAppDrawer1ColorName, newColor.value);
    _appDrawerColor1 = newColor;
    notifyListeners();
  }

  set appDrawerColor2(Color newColor) {
    sharedPreferences.setInt(
        Constants.settingsAppDrawer2ColorName, newColor.value);
    _appDrawerColor2 = newColor;
    notifyListeners();
  }

  set mainScreenColor1(Color newColor) {
    sharedPreferences.setInt(
        Constants.settingsMainScreen1ColorName, newColor.value);
    _mainScreenColor1 = newColor;
    notifyListeners();
  }

  set mainScreenColor2(Color newColor) {
    sharedPreferences.setInt(
        Constants.settingsMainScreen2ColorName, newColor.value);
    _mainScreenColor2 = newColor;
    notifyListeners();
  }

  set mainScreenColor3(Color newColor) {
    sharedPreferences.setInt(
        Constants.settingsMainScreen3ColorName, newColor.value);
    _mainScreenColor3 = newColor;
    notifyListeners();
  }

  set mainScreenColor4(Color newColor) {
    sharedPreferences.setInt(
        Constants.settingsMainScreen4ColorName, newColor.value);
    _mainScreenColor4 = newColor;
    notifyListeners();
  }

  void restoreDefaultColors() {
    appDrawerColor1 = _defaultAppdrawerColor1;
    appDrawerColor2 = _defaultAppdrawerColor2;
    backgroundColor1 = _defaultBackgroundColor1;
    backgroundColor2 = _defaultAppdrawerColor2;
    mainScreenColor1 = _defaultMainScreenColor1;
    mainScreenColor2 = _defaultMainScreenColor2;
    mainScreenColor3 = _defaultMainScreenColor3;
    mainScreenColor4 = _defaultMainScreenColor4;
  }

  void setDarkMode() {
    appDrawerColor1 = defaultAppdrawerColorDarkMode1;
    appDrawerColor2 = defaultAppdrawerColorDarkMode2;
    backgroundColor1 = defaultBackgroundColorDarkMode1;
    backgroundColor2 = defaultAppdrawerColorDarkMode2;
    mainScreenColor1 = defaultMainScreenColorDarkMode1;
    mainScreenColor2 = defaultMainScreenColorDarkMode2;
    mainScreenColor3 = defaultMainScreenColorDarkMode3;
    mainScreenColor4 = defaultMainScreenColorDarkMode4;
  }

  void setTronMode() {
    appDrawerColor1 = defaultAppdrawerColorTronMode1;
    appDrawerColor2 = defaultAppdrawerColorTronMode2;
    backgroundColor1 = defaultBackgroundColorTronMode1;
    backgroundColor2 = defaultAppdrawerColorTronMode2;
    mainScreenColor1 = defaultMainScreenColorTronMode1;
    mainScreenColor2 = defaultMainScreenColorTronMode2;
    mainScreenColor3 = defaultMainScreenColorTronMode3;
    mainScreenColor4 = defaultMainScreenColorTronMode4;
  }

  void setAllWhite() {
    appDrawerColor1 = Colors.white;
    appDrawerColor2 = Colors.white;
    backgroundColor1 = Colors.white;
    backgroundColor2 = Colors.white;
    mainScreenColor1 = Colors.white;
    mainScreenColor2 = Colors.white;
    mainScreenColor3 = Colors.white;
    mainScreenColor4 = Colors.white;
  }
}
