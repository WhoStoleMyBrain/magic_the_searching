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

  static String buildCumulativeQuery(List<String> options, String keyword) {
    if (options.isEmpty) {
      return '';
    }
    // } else if (options.length == 1) {
    //   return '$keyword:${options.first}';
    // }
    return options.fold(
        "", (previousValue, element) => '$previousValue $keyword:$element');
    // return options.reduce((value, element) => '$value $keyword:$element');
  }

  static Future<void> startSearchForCard(
      BuildContext ctx,
      String text,
      List<String> languages,
      List<String> creatureTypes,
      List<String> keywordAbilities,
      List<String> cardTypes,
      String mtgSet,
      String cmcValue,
      String cmcCondition,
      Map<String, bool> manaSymbols) async {
    print(
        'creature types: $creatureTypes; keywordAbilities: $keywordAbilities, cardtypes: $cardTypes');
    final cardDataProvider = Provider.of<CardDataProvider>(ctx, listen: false);
    final settings = Provider.of<Settings>(ctx, listen: false);
    bool requestSuccessful;

    String languageQuery = languages.isNotEmpty
        ? languages.map((language) => "lang:$language").join(' ')
        : '';
    String creatureTypesQuery = buildCumulativeQuery(creatureTypes, 't');
    String cardTypesQuery = buildCumulativeQuery(cardTypes, 't');
    String keywordAbilitiesQuery =
        buildCumulativeQuery(keywordAbilities, 'keyword');
    // String creatureTypeQuery = creatureType.isNotEmpty ? "t:$creatureType" : '';
    // String keywordAbilityQuery =
    //     keywordAbility.isNotEmpty ? 'keyword:$keywordAbility' : '';
    // String cardTypeQuery = cardType.isNotEmpty ? "t:$cardType" : '';
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
        "$text $languageQuery $creatureTypesQuery $cardTypesQuery $setQuery $cmcQuery $manaSymbolQuery $keywordAbilitiesQuery"
            .trim();
    cardDataProvider.languages = languages;
    cardDataProvider.isStandardQuery = true;
    cardDataProvider.queryParameters = ScryfallQueryMaps.searchMap;
    print('Using query: ${cardDataProvider.query}');
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
