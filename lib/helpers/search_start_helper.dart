// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:magic_the_searching/helpers/scryfall_query_maps.dart';
import 'package:provider/provider.dart';

import '../providers/card_data_provider.dart';
import '../providers/history.dart';
import '../providers/settings.dart';
import '../widgets/enter_search_term.dart';

class SearchStartHelper {
  static final SearchStartHelper _searchStartHelper =
      SearchStartHelper._internal();
  factory SearchStartHelper() {
    return _searchStartHelper;
  }
  SearchStartHelper._internal();
  static String prefillValue = '';

  // static void startEnterSearchTerm(
  //   BuildContext ctx,
  // ) {
  //   showModalBottomSheet(
  //     context: ctx,
  //     builder: (bCtx) {
  //       return GestureDetector(
  //         onTap: () {},
  //         child: EnterSearchTerm(
  //           prefillValue: prefillValue,
  //           startSearchForCard: (text, languages) {
  //             return SearchStartHelper.startSearchForCard(
  //               ctx,
  //               text,
  //               languages,
  //             );
  //           },
  //         ),
  //       );
  //     },
  //   ).whenComplete(() {
  //     SearchStartHelper.prefillValue = '';
  //     final history = Provider.of<History>(ctx, listen: false);
  //     history.openModalSheet = false;
  //   });
  // }

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
        "$text $languageQuery $creatureTypeQuery $cardTypeQuery $setQuery $cmcQuery $manaSymbolQuery"
            .trim();
    cardDataProvider.languages = languages;
    cardDataProvider.isStandardQuery = true;
    cardDataProvider.queryParameters = ScryfallQueryMaps.searchMap;
    if (settings.useLocalDB) {
      // print('processing locally...');
      requestSuccessful = await cardDataProvider.processQueryLocally();
    } else {
      print('using Scryfall API...');
      requestSuccessful = await cardDataProvider.processQuery();
      print('Request successful? $requestSuccessful');
    }
    if (!requestSuccessful) {
      showFailedQuery(ctx, text);
    }
  }
}
