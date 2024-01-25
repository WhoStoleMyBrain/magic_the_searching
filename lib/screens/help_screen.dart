import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as url;
import '../widgets/all_help_messages.dart';
import '../widgets/app_drawer.dart';
import '../widgets/help_message.dart';

class HelpScreen extends StatelessWidget {
  static const routeName = '/help-screen';
  const HelpScreen({super.key});

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
                        url.launchUrl(Uri.parse(
                            'https://www.w3schools.com/sql/sql_wildcards.asp'));
                      },
                  ),
                  const TextSpan(
                    text:
                        '\nIf you use the Scryfall API you can use the same syntax that scryfall uses. Therefore you can also search for creature types (e.g. \'t:goblin\') '
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
                        url.launchUrl(
                            Uri.parse('https://scryfall.com/docs/syntax'));
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
