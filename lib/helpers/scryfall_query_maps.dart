import 'package:magic_the_searching/helpers/constants.dart';

class ScryfallQueryMaps {
  static Map<String, String> searchMap = {
    'include_multilingual': 'true',
    'lang': 'any',
  };

  static Map<String, String> inEnglishMap = {
    'include_multilingual': 'true',
    'lang': 'en',
    'unique': 'cards',
  };

  static Map<String, String> versionMap = {
    'unique': 'art',
  };

  static Map<String, String> printsMap = {
    'unique': 'prints',
  };

  static Map<String, String> inUserLanguageMap(Languages userLanguage) {
    return {
      'include_multilingual': 'true',
      'lang': userLanguage.name,
      'unique': 'cards',
    };
  }
}
