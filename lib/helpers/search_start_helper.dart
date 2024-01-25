import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:magic_the_searching/helpers/scryfall_query_maps.dart';
import 'package:provider/provider.dart';

import '../providers/card_data_provider.dart';
import '../providers/settings.dart';

class SearchStartHelper {
  static final SearchStartHelper _searchStartHelper =
      SearchStartHelper._internal();
  factory SearchStartHelper() {
    return _searchStartHelper;
  }
  SearchStartHelper._internal();
  static String prefillValue = '';

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
      BuildContext ctx,
      String text,
      List<String> languages,
      String creatureType,
      String keywordAbility,
      String cardType,
      String mtgSet,
      String cmcValue,
      String cmcCondition,
      Map<String, bool> manaSymbols) async {
    final cardDataProvider = Provider.of<CardDataProvider>(ctx, listen: false);
    final settings = Provider.of<Settings>(ctx, listen: false);
    bool requestSuccessful;

    String languageQuery = languages.isNotEmpty
        ? languages.map((language) => "lang:$language").join(' ')
        : '';
    String creatureTypeQuery = creatureType.isNotEmpty ? "t:$creatureType" : '';
    String keywordAbilityQuery =
        keywordAbility.isNotEmpty ? 'keyword:$keywordAbility' : '';
    String cardTypeQuery = cardType.isNotEmpty ? "t:$cardType" : '';
    String setQuery = mtgSet.isNotEmpty ? "e:$mtgSet" : '';
    String cmcQuery = cmcValue != ''
        ? "mv$cmcCondition$cmcValue"
        : ''; //TODO Fix this != 0 part
    String manaSymbolQuery = manaSymbols.isNotEmpty
        ? manaSymbols.entries
            .where((entry) => entry.value == true)
            .map((entry) => "m:${entry.key}")
            .join(' ')
        : '';

    cardDataProvider.query =
        "$text $languageQuery $creatureTypeQuery $cardTypeQuery $setQuery $cmcQuery $manaSymbolQuery $keywordAbilityQuery"
            .trim();
    cardDataProvider.languages = languages;
    cardDataProvider.isStandardQuery = true;
    cardDataProvider.queryParameters = ScryfallQueryMaps.searchMap;
    if (settings.useLocalDB) {
      // print('processing locally...');
      requestSuccessful = await cardDataProvider.processQueryLocally();
    } else {
      if (kDebugMode) {
        print('using Scryfall API...');
      }
      requestSuccessful = await cardDataProvider.processQuery();
      if (kDebugMode) {
        print('Request successful? $requestSuccessful');
      }
    }
    if (!requestSuccessful) {
      showFailedQuery(ctx, text);
    }
  }
}
