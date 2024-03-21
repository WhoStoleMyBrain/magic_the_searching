import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart' as url;
import '../helpers/navigation_helper.dart';
import '../providers/color_provider.dart';
import '../widgets/all_help_messages.dart';
import '../widgets/app_drawer.dart';
import '../models/help_message.dart';

class HelpScreen extends StatefulWidget {
  static const routeName = '/help-screen';
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final List<bool> _isOpen =
      List.filled(AllHelpMessages.numberOfMessages, false);
  double smallFontSize = 16;
  double largeFontSize = 18;

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

  ExpansionPanel helpMessageToText(HelpMessage helpMessage, int index) {
    return ExpansionPanel(
        backgroundColor: Colors.transparent,
        canTapOnHeader: true,
        isExpanded: _isOpen[index],
        headerBuilder: (context, isExpanded) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            child: Text(helpMessage.title,
                style: TextStyle(
                    fontSize: largeFontSize, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
          );
        },
        body: Text(
          helpMessage.message,
          style: TextStyle(fontSize: smallFontSize),
          textAlign: TextAlign.left,
        ));
  }

  @override
  Widget build(BuildContext context) {
    ColorProvider colorProvider = Provider.of<ColorProvider>(context);
    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        if (!Navigator.canPop(context)) {
          NavigationHelper.showExitAppDialog(context);
        }
      },
      child: Container(
        alignment: Alignment.topLeft,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.bottomRight,
            stops: const [0.1, 0.9],
            colors: [
              colorProvider.backgroundColor1,
              colorProvider.backgroundColor2,
            ],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: const Text('Help'),
          ),
          drawer: const AppDrawer(),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(12.0),
            child: ExpansionPanelList(
              elevation: 0,
              dividerColor: Colors.black54,
              materialGapSize: 8,
              expandedHeaderPadding: const EdgeInsets.symmetric(vertical: 8),
              expansionCallback: (i, isOpen) => setState(() {
                _isOpen[i] = isOpen;
              }),
              children: [
                helpMessageToText(AllHelpMessages.linksToWeb, 0),
                helpMessageToText(AllHelpMessages.dataOrigin, 1),
                helpMessageToText(AllHelpMessages.downloadDB, 2),
                helpMessageToText(AllHelpMessages.localDB, 3),
                helpMessageToText(AllHelpMessages.showImages, 4),
                helpMessageToText(AllHelpMessages.search, 5),
                helpMessageToText(AllHelpMessages.cardDetailScreen, 6),
                getAdvancesSearchHelpMessage(context, 7),
                helpMessageToText(AllHelpMessages.cardNotFound, 8),
                helpMessageToText(AllHelpMessages.prices, 9),
                helpMessageToText(AllHelpMessages.historyScreen, 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ExpansionPanel getAdvancesSearchHelpMessage(BuildContext context, int index) {
    return ExpansionPanel(
        backgroundColor: Colors.transparent,
        canTapOnHeader: true,
        isExpanded: _isOpen[index],
        headerBuilder: (context, isExpanded) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            child: Text(AllHelpMessages.advancedSearch.title,
                style: TextStyle(
                    fontSize: largeFontSize, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
          );
        },
        body: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'The short answer is: maybe. \n'
                    'The long answer is: It depends on your situation. If you use the local database, you can query that database with the same syntax every SQLite database uses. '
                    'Hereby ONLY the name of the card can be searched. For more information on this syntax click here: ',
                style: TextStyle(fontSize: smallFontSize, color: Colors.black),
              ),
              TextSpan(
                text: 'SQL Query Input',
                style: TextStyle(
                    fontSize: smallFontSize,
                    color: Theme.of(context).colorScheme.primary),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    url.launchUrl(Uri.parse(
                        'https://www.w3schools.com/sql/sql_wildcards.asp'));
                  },
              ),
              TextSpan(
                text:
                    '\nIf you use the Scryfall API you can use the same syntax that scryfall uses. Therefore you can also search for creature types (e.g. \'t:goblin\') '
                    'or any other search criterion Scryfall allows. This is already being used in the background for all options available in the search mask, i.e. set, colors or creature types. For more information, click here: ',
                style: TextStyle(fontSize: smallFontSize, color: Colors.black),
              ),
              TextSpan(
                text: 'Scryfall Syntax',
                style: TextStyle(
                    fontSize: smallFontSize,
                    color: Theme.of(context).colorScheme.primary),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    url.launchUrl(
                        Uri.parse('https://scryfall.com/docs/syntax'));
                  },
              ),
            ],
          ),
        ));
  }
}
