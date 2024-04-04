enum Languages {
  en('English', 'en'),
  sp('Spanish', 'es'),
  fr('French', 'fr'),
  de('German', 'de'),
  it('Italian', 'it'),
  pt('Portuguese', 'pt'),
  ja('Japanese', 'ja'),
  ko('Korean', 'ko'),
  ru('Russian', 'ru'),
  zhs('Simplified Chinese', 'zh-Latn'),
  zht('Traditional Chinese', 'zh');

  const Languages(this.longName, this.googleMlKitId);
  final String longName;
  final String googleMlKitId;
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
  static const imageTextMapLanguages = 'languages';

  static const tutorialSeen = "tutorialSeen";

  static const settingsBackgroundColor1Name = "backgroundColor1";
  static const settingsBackgroundColor2Name = "backgroundColor2";
  static const settingsAppDrawer1ColorName = "appdrawerColor1";
  static const settingsAppDrawer2ColorName = "appdrawerColor2";
  static const settingsMainScreen1ColorName = "mainScreenColor1";
  static const settingsMainScreen2ColorName = "mainScreenColor2";
  static const settingsMainScreen3ColorName = "mainScreenColor3";
  static const settingsMainScreen4ColorName = "mainScreenColor4";

  static const privacyInformation1 =
      "This app does not in any way collect usage data or personal data of any kind.";
  static const privacyInformation2 =
      "However, for functionality the following device permissions are required:";
  static const privacyInformation3 =
      "Camera: If you wish to quick search for cards, access to the camera is obligatory. However, the images taken are only stored as long as they are needed to process the task requested by the user, and discarded immediately afterwards.";
  static const privacyInformation41 =
      "Internet: Since this app does obtain its data from the open API at";
  static const privacyInformation42 = " Scryfall.com ";
  static const privacyInformation43 =
      "an internet connection and access to such internet connection is required for the app to function.";
  static const privacyInformation5 =
      "User History: Using the app will result in a search history of the last 7 days to be stored on the device. This information is only stored locally and not sent to any external service. It is solely being used for its intended function, i.e. displaying the information on the screen and making quick searches available.";
  static const privacyInformation6 =
      "For a complete privacy information please refer to this link: ";
  static const privacyInformation7 =
      "https://www.freeprivacypolicy.com/live/bfd459f6-0363-4fa7-9154-d2a92613e753";

  static const aboutPage1 =
      "If you enjoy this app, feel free to share it with your friends and other Magic the Gathering entusiasts. I am constantly trying to improve the app, and as such your feedback as a user is most important to me!\nIf you have any suggestions for improvements or find any bugs or weird behaviour, please contact me either at the google play store, the app store or via mail at ";
  static const aboutPage2 =
      "\n\nAlso, if you like my work and want to buy me a coffee, you can do so over at \n";

  static const buyMeACoffee = "https://www.buymeacoffee.com/marcowetter";

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
