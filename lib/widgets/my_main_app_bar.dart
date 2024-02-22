import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../enums/query_location.dart';
import '../helpers/constants.dart';
import '../helpers/search_start_helper.dart';
import '../providers/card_data_provider.dart';
import '../providers/scryfall_provider.dart';
import '../providers/settings.dart';
import '../screens/search_page.dart';

class MyMainAppBar extends StatefulWidget {
  const MyMainAppBar({super.key});

  @override
  State<MyMainAppBar> createState() => _MyMainAppBarState();
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

  @override
  Widget build(BuildContext context) {
    final cardDataProvider =
        Provider.of<CardDataProvider>(context, listen: true);
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
      actions: [...getActions(context, cardDataProvider)],
    );
  }

  List<Widget> getActions(
      BuildContext context, CardDataProvider cardDataProvider) {
    if (cardDataProvider.cards.isNotEmpty && title != '') {
      return [
        getIconDisplayQueryMethod(cardDataProvider),
        iconButtonEditQuery(context),
      ];
    } else {
      return [
        getIconDisplayQueryMethod(cardDataProvider),
        iconButtonEmpty(),
      ];
    }
  }

  Widget getIconDisplayQueryMethod(CardDataProvider cardDataProvider) {
    return switch (cardDataProvider.queryLocation) {
      QueryLocation.local =>
        const Text('LCL', style: TextStyle(color: Colors.black)),
      QueryLocation.scryfall =>
        const Text('SCR', style: TextStyle(color: Colors.deepPurple)),
      QueryLocation.none =>
        const Text('NON', style: TextStyle(color: Colors.green)),
    };
  }

  IconButton iconButtonEmpty() {
    return const IconButton(
      icon: Icon(Icons.mode),
      color: Colors.grey,
      disabledColor: Colors.grey,
      onPressed: null,
    );
  }

  IconButton iconButtonEditQuery(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.mode),
      color: Colors.black,
      onPressed: () async {
        ScryfallProvider scryfallProvider =
            Provider.of<ScryfallProvider>(context, listen: false);
        final Map<String, dynamic> prefilledValues =
            SearchStartHelper.mapQueryToPrefilledValues(
                title, scryfallProvider);
        await Navigator.of(context)
            .push(
          MaterialPageRoute(
            builder: (context) => SearchPage(prefilledValues: prefilledValues),
          ),
        )
            .then((value) {
          if (value != null) {
            SearchStartHelper.startSearchForCard(
              context,
              value[Constants.contextSearchTerm],
              value[Constants.contextLanguages],
              value[Constants.contextCreatureTypes],
              value[Constants.contextKeywords],
              value[Constants.contextCardTypes],
              value[Constants.contextSet],
              value[Constants.contextCmcValue],
              value[Constants.contextCmcCondition],
              value[Constants.contextColors],
            );
          }
        });
      },
    );
  }
}
