import 'package:flutter/material.dart';
import 'package:magic_the_searching/helpers/db_helper.dart';
import 'package:magic_the_searching/helpers/scryfall_query_maps.dart';
import 'package:provider/provider.dart';

import '../providers/card_data_provider.dart';
import '../providers/settings.dart';
import '../widgets/enter_search_term.dart';
import '../widgets/card_display.dart';

class SearchStartHelper {
  static void startEnterSearchTerm(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (bCtx) {
        return GestureDetector(
          onTap: () {},
          child: EnterSearchTerm(
            startSearchForCard: (text, languages) {
              return SearchStartHelper.startSearchForCard(ctx, text, languages);
            },
          ),
        );
      },
    );
  }

  static Future<void> showFailedQuery(BuildContext ctx, String query) async {
    return showDialog<void>(
      context: ctx,
      builder: (bCtx) {
        return AlertDialog(
          title: const Text('No results found'),
          content: SingleChildScrollView(
              child: Text('No results matching \'$query\' found.')),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(bCtx).pop();
              },
              child: const Text('Okay'),
            )
          ],
        );
      },
    );
  }

  static Future<void> startSearchForCard(
      BuildContext ctx, String text, List<String> languages) async {
    final cardDataProvider = Provider.of<CardDataProvider>(ctx, listen: false);
    final settings = Provider.of<Settings>(ctx, listen: false);
    bool requestSuccessful;
    CardImageDisplay.pictureLoaded = false;
    cardDataProvider.query = text;
    cardDataProvider.languages = languages;
    cardDataProvider.isStandardQuery = true;
    cardDataProvider.dbHelperFunction = DBHelper.getHistoryData;
    cardDataProvider.queryParameters = ScryfallQueryMaps.searchMap;
    if (settings.useLocalDB) {
      print('processing locally...');
      requestSuccessful = await cardDataProvider.processQueryLocally();
    } else {
      print('using Scryfall API...');
      requestSuccessful = await cardDataProvider.processQuery();
    }
    if (!requestSuccessful) {
      showFailedQuery(ctx, text);
    }
  }
}
