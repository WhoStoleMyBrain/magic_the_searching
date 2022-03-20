import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/card_data_provider.dart';
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
    CardImageDisplay.pictureLoaded = false;
    cardDataProvider.query = text;
    cardDataProvider.languages = languages;
    bool requestSuccessful = await cardDataProvider.processSearchQuery();
    if (!requestSuccessful) {
      showFailedQuery(ctx, text);
    }
  }
}
