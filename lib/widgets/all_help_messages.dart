import '../models/help_message.dart';

class AllHelpMessages {
  static int numberOfMessages = 11;
  static HelpMessage dataOrigin = HelpMessage(
    title: 'Where does the card information and images come from?',
    message:
        'The data and images you see in this app is provided by Scryfall via their open API.',
  );
  static HelpMessage linksToWeb = HelpMessage(
      title: 'Can I open any card also on the web?',
      message:
          'Yes you can. After you clicked on a card, scroll down to see three links. Those will open that specific card on scryfall, cardmarket and TCGPlayer, respectively.');
  static HelpMessage downloadDB = HelpMessage(
    title: 'What does the \'Download\' button in the settings screen do?',
    message:
        'Scryfall provides datasets with most or all cards in their database. Clicking the button will download the this data, but only containing one single version per card, preferably in English.'
        'This data is then stored on the device inside a SQLite database. While \'Use local DB\' is switched on, the cards are searched in this local database, '
        'instead of requesting data from Scryfall. This enables you to perform basic searches even without internet connection.',
  );
  static HelpMessage localDB = HelpMessage(
    title:
        'What does the switch \'Use local DB\' do in the settings screen do?',
    message:
        'After having downloaded data from Scryfall the local SQLite database is searched instead of requesting data from Scryfall. '
        'Please note, that while using the local database, you do not necessarily need an internet connection, the provided data might not be up to date and not reflect the current price of any card.'
        'Check the date of your local database in the settings screen.',
  );
  static HelpMessage showImages = HelpMessage(
    title: 'What does the switch \'Show Images\' do?',
    message: 'If switched on, images of cards are displayed.\n'
        'If switched off, instead of an image only the title, oracle text and set name will be displayed instead. '
        'This is intended to reduce mobile data usage, since images can be quite large and for rather open searches (i.e. the search term \'Goblin\' will have many results) many images will be loaded.'
        'Please note, that for cards from specific sets or with special artworks, the correct identification without image is almost impossible. '
        'Nevertheless, this can still give a rough estimate on what you can expect while reducing mobile data usage significantly.',
  );
  static HelpMessage search = HelpMessage(
    title: 'How do I search for cards?',
    message:
        'Either by typing the name of the card into the search mask or by taking a picture of the card. Taking a picture will try to search for the first line of text on the image, '
        'so make sure that there is no background text, and that the title is readable.',
  );
  static HelpMessage cardDetailScreen = HelpMessage(
    title: 'What do the buttons on the detailed card screen do?',
    message:
        '\'In [Language]\' searches for the same card, but in the preferred language specified in the settings language.\n'
        '\'All Prints\' searches for the same card, but includes all prints. This includes both different artworks and same artwork prints in different sets. \n'
        '\'All Arts\' searches specifically only for different art versions. If any art was printed in different sets, the first result is taken.',
  );

  static HelpMessage advancedSearch = HelpMessage(
    title: 'Can I use advanced search methods to search for cards?',
    message: 'The short answer is: maybe. \n'
        'The long answer is: It depends on your situation. If you use the local database, you can query that database with the same syntax every SQLite database uses. '
        'Hereby ONLY the name of the card can be searched. For more information on this syntax read here... \n'
        'If you use the Scryfall API you can use the same syntax that scryfall uses. Therefore you can also search for creature types (e.g. \'t:goblin\') '
        'or any other search criterion Scryfall allows. For more information, read here...',
  );
  static HelpMessage cardNotFound = HelpMessage(
    title: 'My card was not found. What can I do?',
    message:
        'This depends on your situation. First of all, if you use the local database, try using scryfall instead, '
        'or try searching for the card in English if it is in any other language. If you are using the Scryfall API and the card is not in English, '
        'try searching for the card but prefix your search with \'l:[language-code]\', without the quotes and where you replace the '
        'brackets with the corresponding language code. Scryfall does support most languages in which printed official MtG cards appear. \n'
        'Example: \'l:de Armee der Verdammten\'',
  );
  static HelpMessage prices = HelpMessage(
    title: 'What does TCG and CDM mean?',
    message:
        'The prices provided by Scryfall are either in € or in \$. It is assumed that the €-price is the average price of the card at cardmarket (CDM), '
        'while the \$-price is the average price on TCGPlayer (TCG). For more refined results click on the card and then scroll down. There will be links available to open the card in the web on either cardmarket or TCGPlayer.',
  );

  static HelpMessage historyScreen = HelpMessage(
    title: 'What is the history screen?',
    message:
        'Your searches will be saved for 7 days, in case you want to revisit one of your searches. Tapping on any history item will re-search with that specific query. Clicking the edit icon next to a search will open the search mask prefilled with the values from this search.',
  );
}
