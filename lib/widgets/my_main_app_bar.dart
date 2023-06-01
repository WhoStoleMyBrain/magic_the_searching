import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/search_start_helper.dart';
import '../providers/card_data_provider.dart';
import '../providers/settings.dart';
import '../screens/search_page.dart';

class MyMainAppBar extends StatefulWidget {
  MyMainAppBar({Key? key}) : super(key: key);

  @override
  State<MyMainAppBar> createState() => _MyMainAppBarState();

  // @override
  // Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _MyMainAppBarState extends State<MyMainAppBar> {
  bool handedMode = false;
  late bool useLocalDB = false;
  String title = '';
  @override
  void initState() {
    super.initState();
    final settings = Provider.of<Settings>(context, listen: false);
    useLocalDB = settings.useLocalDB;
  }

  void setTitle() {
    final cardDataProvider =
        Provider.of<CardDataProvider>(context, listen: true);
    setState(
      () {
        title = cardDataProvider.query.isNotEmpty
            ? (cardDataProvider.query[0] == '!'
                ? cardDataProvider.query.substring(1)
                : cardDataProvider.query)
            : '';
      },
    );
  }

  Map<String, dynamic> parseSearchString(String search) {
    // This is a placeholder. You will need to implement this method based on your search string format.
    // ...
    Map<String, dynamic> parsed = {
      'searchTerm': '',
      'creatureType': '',
      'cardType': '',
      'set': '',
      'cmcValue': '',
      'cmcCondition': '<',
      'colors': <String, bool>{
        'G': false,
        'R': false,
        'B': false,
        'U': false,
        'W': false,
      },
    };
    List<String> terms = search.split(' ');

    for (String term in terms) {
      // If the term is one of the card types, it's the card type
      // Adjust this to match your actual card type names
      if (term.contains('t:')) {
        if ([
          'Artifact',
          'Battle',
          'Conspiracy',
          'Creature',
          'Emblem',
          'Enchantment',
          'Hero',
          'Instant',
          'Land',
          'Phenomenon',
          'Plane',
          'Planeswalker',
          'Scheme',
          'Sorcery',
          'Tribal',
          'Vanguard',
          'Legendary'
        ]
            .map((e) => e.toLowerCase())
            .contains(term.split(':')[1].toLowerCase())) {
          parsed['cardType'] = term.split(':')[1];
        } else {
          parsed['creatureType'] = term.split(':')[1];
        }
      }
      // If the term is one of the color symbols, it's a color
      // Note that we're assuming color symbols are single characters here
      else if (term.contains('m:')) {
        parsed['colors'][term.split('m:')[1]] = true;
      }
      // If the term is a number, it's the cmcValue
      else if (term.contains('mv')) {
        // mv is of the structure mv[cmcCondition][cmcValue]
        final regExp = RegExp(r'\d+');
        Match? match = regExp.firstMatch(term);
        if (match != null) {
          String number = term.substring(match.start, match.end);
          parsed['cmcValue'] = number;
          parsed['cmcCondition'] = term.substring(2, match.start);
        }
      }
      // If the term contains '=', it's the set
      else if (term.contains('e:')) {
        parsed['set'] = term.split(':')[1];
      }
      // Otherwise, we'll assume it's part of the search term
      else {
        parsed['searchTerm'] += ' ' + term;
      }
    }

    // Clean up the search term
    parsed['searchTerm'] = parsed['searchTerm'].trim();
    print('parsed info:$parsed');
    return parsed;
  }

  @override
  Widget build(BuildContext context) {
    final cardDataProvider =
        Provider.of<CardDataProvider>(context, listen: false);
    setTitle();
    return AppBar(
      title: (cardDataProvider.cards.isNotEmpty && title != '')
          ? Text(
              'Searched for: $title',
              style: const TextStyle(fontSize: 18),
              maxLines: 2,
            )
          : const Text(
              'No search performed yet',
              style: TextStyle(fontSize: 18),
            ),
      actions: [
        (cardDataProvider.cards.isNotEmpty && title != '')
            ? IconButton(
                icon: const Icon(Icons.mode),
                color: Colors.white,
                onPressed: () async {
                  // SearchStartHelper.prefillValue = title;
                  final Map<String, dynamic> prefilledValues =
                      parseSearchString(title);
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          SearchPage(prefilledValues: prefilledValues),
                    ),
                  );
                  if (result != null) {
                    SearchStartHelper.startSearchForCard(
                      context,
                      result['searchTerm'],
                      result['languages'],
                      result['creatureType'],
                      result['cardType'],
                      result['set'],
                      result['cmcValue'],
                      result['cmcCondition'],
                      result['colors'],
                    );
                  }
                },
              )
            : const IconButton(
                icon: Icon(Icons.mode),
                color: Colors.grey,
                disabledColor: Colors.grey,
                onPressed: null,
              ),
      ],
    );
  }
}
