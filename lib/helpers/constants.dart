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
  static const settingUseLocalDB = 'useLocalDB';
  static const settingIsFirstLoaded = 'isFirstLoaded';
  static const placeholderSplitText = 'PLACEHOLDER_SPLIT_TEXT';
  static const loyaltyAssetPath = 'assets/images/Loyalty.svg';
  static const imageTextMapCardName = 'cardName';
  static const imageTextMapCardType = 'cardType';
  static const imageTextMapCreatureType = 'creatureType';

  static const settingsBackgroundColor1Name = "backgroundColor1";
  static const settingsBackgroundColor2Name = "backgroundColor2";
  static const settingsAppDrawer1ColorName = "appdrawerColor1";
  static const settingsAppDrawer2ColorName = "appdrawerColor2";
  static const settingsMainScreen1ColorName = "mainScreenColor1";
  static const settingsMainScreen2ColorName = "mainScreenColor2";
  static const settingsMainScreen3ColorName = "mainScreenColor3";
  static const settingsMainScreen4ColorName = "mainScreenColor4";

  static String defaultTimestamp =
      DateTime.parse("1969-07-20 20:18:04Z").toIso8601String();

  static const createCardInfoTable =
      'CREATE TABLE card_info(id TEXT UNIQUE PRIMARY KEY, oracleId TEXT, scryfallUri TEXT, dateTime DATETIME);';
  static const createCardDetailTable =
      'CREATE TABLE card_detail(id TEXT UNIQUE PRIMARY KEY, name TEXT, printedName TEXT, manaCost TEXT, typeLine TEXT, printedTypeLine TEXT, oracleText TEXT, printedText TEXT, power TEXT, toughness TEXT, loyalty TEXT, setName TEXT, flavorText TEXT, hasTwoSides INTEGER, FOREIGN KEY(id) REFERENCES card_info(id));';
  static const createImageUrisTable =
      'CREATE TABLE image_uris(id TEXT UNIQUE PRIMARY KEY, normal TEXT, small TEXT, FOREIGN KEY(id) REFERENCES card_info(id));';
  static const createCardFacesTable =
      'CREATE TABLE card_faces(id TEXT UNIQUE PRIMARY KEY, normalFront TEXT, smallFront TEXT, normalBack TEXT, smallBack TEXT, FOREIGN KEY(id) REFERENCES card_info(id));';
  static const createPricesTable =
      'CREATE TABLE prices(id TEXT UNIQUE PRIMARY KEY, usd TEXT, usdFoil TEXT, eur TEXT, eurFoil TEXT, FOREIGN KEY(id) REFERENCES card_info(id));';
  static const createPurchaseUrisTable =
      'CREATE TABLE purchase_uris(id TEXT UNIQUE PRIMARY KEY, tcgplayer TEXT, cardmarket TEXT, FOREIGN KEY(id) REFERENCES card_info(id));';

  static const createCardInfoTableIfNotExists =
      'CREATE TABLE IF NOT EXISTS card_info(id TEXT UNIQUE PRIMARY KEY, oracleId TEXT, scryfallUri TEXT, dateTime DATETIME);';
  static const createCardDetailTableIfNotExists =
      'CREATE TABLE IF NOT EXISTS card_detail(id TEXT UNIQUE PRIMARY KEY, name TEXT, printedName TEXT, manaCost TEXT, typeLine TEXT, printedTypeLine TEXT, oracleText TEXT, printedText TEXT, power TEXT, toughness TEXT, loyalty TEXT, setName TEXT, flavorText TEXT, hasTwoSides INTEGER, FOREIGN KEY(id) REFERENCES card_info(id));';
  static const createImageUrisTableIfNotExists =
      'CREATE TABLE IF NOT EXISTS image_uris(id TEXT UNIQUE PRIMARY KEY, normal TEXT, small TEXT, FOREIGN KEY(id) REFERENCES card_info(id));';
  static const createCardFacesTableIfNotExists =
      'CREATE TABLE IF NOT EXISTS card_faces(id TEXT UNIQUE PRIMARY KEY, normalFront TEXT, smallFront TEXT, normalBack TEXT, smallBack TEXT, FOREIGN KEY(id) REFERENCES card_info(id));';
  static const createPricesTableIfNotExists =
      'CREATE TABLE IF NOT EXISTS prices(id TEXT UNIQUE PRIMARY KEY, usd TEXT, usdFoil TEXT, eur TEXT, eurFoil TEXT, FOREIGN KEY(id) REFERENCES card_info(id));';
  static const createPurchaseUrisTableIfNotExists =
      'CREATE TABLE IF NOT EXISTS purchase_uris(id TEXT UNIQUE PRIMARY KEY, tcgplayer TEXT, cardmarket TEXT, FOREIGN KEY(id) REFERENCES card_info(id));';
  static const cardDatabaseTableFileName = 'cardDatabase.db';
}
