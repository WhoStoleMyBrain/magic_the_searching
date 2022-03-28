import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as url;
import '../widgets/app_drawer.dart';

class HelpScreen extends StatelessWidget {
  static const routeName = '/help-screen';
  const HelpScreen({Key? key}) : super(key: key);

  Widget smallDivider() {
    return const SizedBox(
      height: 10,
    );
  }

  Widget largeDivider() {
    return const Divider(
      height: 20,
      thickness: 2,
      color: Colors.black,
    );
  }

  List<Widget> helpMessageToText(HelpMessage helpMessage) {
    return [
      Text(helpMessage.title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center),
      smallDivider(),
      Text(
        helpMessage.message,
        style: const TextStyle(fontSize: 14),
        textAlign: TextAlign.left,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help'),
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            ...helpMessageToText(AllHelpMessages.dataOrigin),
            largeDivider(),
            ...helpMessageToText(AllHelpMessages.downloadDB),
            largeDivider(),
            ...helpMessageToText(AllHelpMessages.localDB),
            largeDivider(),
            ...helpMessageToText(AllHelpMessages.showImages),
            largeDivider(),
            ...helpMessageToText(AllHelpMessages.search),
            largeDivider(),
            ...helpMessageToText(AllHelpMessages.cardDetailScreen),
            largeDivider(),
            // ...helpMessageToText(AllHelpMessages.advancedSearch), // does not work because I want to be able to launch URLs here.
            // largeDivider(),
            Text(AllHelpMessages.advancedSearch.title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            smallDivider(),
            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: 'The short answer is: maybe. \n'
                        'The long answer is: It depends on your situation. If you use the local database, you can query that database with the same syntax every SQLite database uses. '
                        'Hereby ONLY the name of the card can be searched. For more information on this syntax click here: ',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  TextSpan(
                    text: 'SQL Query Input',
                    style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.primary),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        url.launch(
                            'https://www.w3schools.com/sql/sql_wildcards.asp');
                      },
                  ),
                  const TextSpan(
                    text: '\nIf you use the Scryfall API you can use the same syntax that scryfall uses. Therefore you can also search for creature types (e.g. \'t:goblin\') '
                        'or any other search criterion Scryfall allows. For more information, click here: ',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  TextSpan(
                    text: 'Scryfall Syntax',
                    style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.primary),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        url.launch(
                            'https://scryfall.com/docs/syntax');
                      },
                  ),
                ],
              ),
            ),
            largeDivider(),
            ...helpMessageToText(AllHelpMessages.cardNotFound),
            largeDivider(),
            ...helpMessageToText(AllHelpMessages.prices),
            largeDivider(),
            ...helpMessageToText(AllHelpMessages.historyScreen),
          ],
        ),
      ),
    );
  }
}

class HelpMessage {
  String title;
  String message;

  HelpMessage({required this.title, required this.message});
}

class AllHelpMessages {
  static HelpMessage search = HelpMessage(
      title: 'How do I search for cards?',
      message:
          'Either by typing the name or by taking a picture of the card. Taking a picture will try to search for the first line of text on the image, '
          'so make sure that there is no background text, and that the title is readable.');
  static HelpMessage localDB = HelpMessage(
      title: 'What does the switch \'Use local DB\' do?',
      message:
          'After having downloaded the data from Scryfall the local DB is searched instead of requesting data from Scryfall.');
  static HelpMessage downloadDB = HelpMessage(
      title: 'What does \'Refresh local DB\' do?',
      message:
          'Scryfall provides in its API also bulk data. Clicking the button will download the bulk data, but only containing one single version per card, preferably in English.'
          'This data is then stored on the device inside of a SQLite database. While \'use local DB\' is switched on, the cards are searched in this local database, '
          'instead of requesting data from Scryfall. This enables you to perform basic searches even without internet connection.');
  static HelpMessage showImages = HelpMessage(
      title: 'What does the switch \'Show Images\' do?',
      message: 'If switched on, images of the found cards are displayed.\n'
          'If switched off, instead of an image only the title, oracle text and set name will be displayed instead. This is intended to reduce mobile data usage.');
  static HelpMessage cardNotFound = HelpMessage(
      title: 'My card is not found. What can I do?',
      message:
          'This depends on your situation. First of all, if you use the local database, try switching the local database off, '
          'or try searching for the card in English if it is in any other language. If you are using the Scryfall API and the card is not in English, '
          'try searching for the card but prefix your search with \'l:[language-code]\', without the quotes and where you replace the '
          'brackets with the corresponding language code. Scryfall does support most languages in which printed official MtG cards appear. \n'
          'Example: \'l:de Armee der Verdammten\'');
  static HelpMessage advancedSearch = HelpMessage(
      title: 'Can I use advanced search methods to search for cards?',
      message: 'The short answer is: maybe. \n'
          'The long answer is: It depends on your situation. If you use the local database, you can query that database with the same syntax every SQLite database uses. '
          'Hereby ONLY the name of the card can be searched. For more information on this syntax read here... \n'
          'If you use the Scryfall API you can use the same syntax that scryfall uses. Therefore you can also search for creature types (e.g. \'t:goblin\') '
          'or any other search criterion Scryfall allows. For more information, read here...');
  static HelpMessage cardDetailScreen = HelpMessage(
      title: 'What do the buttons on the detailed card screen do?',
      message:
          '\'In English\' searches for the same card, but in the English language. This does basically nothing if your card is already in English. \n'
          '\'All Prints\' searches for the same card, but includes all prints. This includes both different artworks and same artwork prints in different sets. \n'
          '\'All Arts\' searches specifically only for different art versions. If any art was printed in different sets, the first result is taken.');
  static HelpMessage prices = HelpMessage(
      title: 'What does TCG and CDM mean?',
      message:
          'The prices provided by Scryfall are given in € or \$. It is assumed that the €-price is the average price of the card at cardmarket (CDM), '
          'while the \$-price is the average price on TCGPlayer (TCG).');
  static HelpMessage dataOrigin = HelpMessage(
      title: 'Where does the data come from?',
      message: 'This App uses the Scryfall API as backend.');
  static HelpMessage historyScreen = HelpMessage(
      title: 'What is the history screen?',
      message:
          'Your searches will be saved for 7 days, in case you want to revisit one of your searches. Tapping on any history item will re-search with that specific query.');
}
