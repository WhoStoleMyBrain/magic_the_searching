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
  //!"Barkchannel+Pathway+%2F%2F+Tidechannel+Pathway"+include%3Aextras&unique=prints

  static Map<String, String> printsMap = {
    'unique': 'prints',
  };
}
