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
}
