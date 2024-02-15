enum Languages {
  en('English'),
  sp('Spanish'),
  fr('French'),
  de('German'),
  it('Italian'),
  pt('Portuguese'),
  ja('Japanese'),
  ko('Korean'),
  ru('Russian'),
  zhs('Simplified Chinese'),
  zht('Traditional Chinese');

  const Languages(this.longName);
  final String longName;
}

class Constants {
  static const urlKeywordAbilities =
      'https://api.scryfall.com/catalog/keyword-abilities';
  static const urlCreatureTypes =
      'https://api.scryfall.com/catalog/creature-types';
  static const urlSets = 'https://api.scryfall.com/sets';
  static const contextSearchTerm = 'searchTerm';
  static const contextLanguages = 'languages';
  static const contextCreatureTypes = 'selectedCreatureTypes';
  static const contextCardTypes = 'selectedCardTypes';
  static const contextKeywords = 'selectedKeywordAbilities';
  static const contextSet = 'set';
  static const contextCmcValue = 'cmcValue';
  static const contextCmcCondition = 'cmcCondition';
  static const contextColors = 'colors';
  static const contextManaSymbols = 'colors';
  static const settingUserLanguage = 'userLanguage';
  static const settingUseImagesFromNet = 'useImagesFromNet';
  static const settingDbUpdatedAt = 'dbUpdatedAt';
  static const placeholderSplitText = 'PLACEHOLDER_SPLIT_TEXT';
  static const loyaltyAssetPath = 'assets/images/Loyalty.svg';
}
