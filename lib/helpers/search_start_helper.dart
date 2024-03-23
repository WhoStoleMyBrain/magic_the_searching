import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../enums/query_location.dart';
import '../helpers/connectivity_helper.dart';
import '../helpers/db_helper.dart';
import '../helpers/scryfall_query_maps.dart';
import '../models/mtg_set.dart';
import '../providers/scryfall_provider.dart';
import '../providers/card_data_provider.dart';
import '../providers/settings.dart';

import 'constants.dart';

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
          titlePadding: const EdgeInsets.all(24.0),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(32))),
          backgroundColor: Colors.blueGrey.shade200,
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
    String firstEntry = options.first;
    if (options.length == 1) {
      return '$keyword:$firstEntry';
    }

    return options.sublist(1).fold('$keyword:$firstEntry',
        (previousValue, element) => '$previousValue $keyword:$element');
  }

  static List<String> _getItemsWithStringStart(
      List<String> input, String match) {
    return input
        .where((element) => element.contains(match))
        .map((e) => e.split(match)[1])
        .toList();
  }

  static Map<String, dynamic> mapQueryToPrefilledValues(
      String query, ScryfallProvider scryfallProvider) {
    final splitQuery = query.split(' ');
    if (kDebugMode) {
      print('splitQuery: ${splitQuery.asMap()}');
    }
    // fetching the correct parts of the split query
    List<String> sets = _getItemsWithStringStart(splitQuery, 'set:');
    List<String> manaValues = _getItemsWithStringStart(splitQuery, 'mv');
    List<String> manaSymbols = _getItemsWithStringStart(splitQuery, 'm:');
    Iterable<String> keywords =
        splitQuery.where((element) => element.contains('keyword:'));
    Iterable<String> types =
        splitQuery.where((element) => element.contains('t:'));

    // fetch set
    MtGSet? foundSet = scryfallProvider.sets
        .where((element) => sets.contains(element.code))
        .toList()
        .firstOrNull;

    // fetch cmc value
    String foundCmcValues = manaValues.isNotEmpty ? manaValues.first : '';
    RegExp conditionRegExp = RegExp(r'[<|>|<=|>=|=]');
    RegExp numberRegExp = RegExp(r'\d');
    String? cmcCondition = conditionRegExp.firstMatch(foundCmcValues)?[0];
    String? cmcValue = numberRegExp.firstMatch(foundCmcValues)?[0];

    // fetch colors
    List<String> colors = ['W', 'U', 'B', 'R', 'G'];
    Map<String, bool> mappedManaSymbols = colors.asMap().map(
          (key, value) => MapEntry(value, manaSymbols.contains(value)),
        );

    // fetch rest of the query
    String? restOfQuery = _getRestOfQuery(splitQuery);

    List<String> cardTypes = _getCardTypes(types, scryfallProvider);
    // fetch creature types
    List<String> creatureTypes = _getCreatureTypes(types, scryfallProvider);
    // fetch keywords
    List<String>? foundKeywords = _getKeywords(keywords, scryfallProvider);

    return {
      Constants.contextCreatureTypes: creatureTypes,
      Constants.contextKeywords: foundKeywords,
      Constants.contextCardTypes: cardTypes,
      Constants.contextSet: foundSet,
      Constants.contextManaSymbols: mappedManaSymbols,
      Constants.contextSearchTerm: restOfQuery,
      Constants.contextCmcCondition: cmcCondition,
      Constants.contextCmcValue: cmcValue,
    };
  }

  static List<String>? _getKeywords(
      Iterable<String> keywords, ScryfallProvider scryfallProvider) {
    try {
      return keywords
          .map((e) => scryfallProvider.mappedKeywordAbilities.map(
              (key, value) => MapEntry(value, key))[e.split('keyword:')[1]]!)
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Unhandled error: $e');
      }
      return null;
    }
  }

  static List<String> _getEntriesFromReference(
      Iterable<String> query, Iterable<String> reference, String split) {
    return query
        .where((element) => reference.contains(element.split(split)[1]))
        .toList();
  }

  static List<String> _getCreatureTypes(
      Iterable<String> types, ScryfallProvider scryfallProvider) {
    List<String> creatureTypes = _getEntriesFromReference(
        types, scryfallProvider.mappedCreatureTypes.values, 't:');
    creatureTypes = creatureTypes
        .map(
          (e) => scryfallProvider.mappedCreatureTypes
              .map((key, value) => MapEntry(value, key))[e.split('t:')[1]]!,
        )
        .toList();
    return creatureTypes;
  }

  static List<String> _getCardTypes(
      Iterable<String> types, ScryfallProvider scryfallProvider) {
    List<String> cardTypes =
        _getEntriesFromReference(types, scryfallProvider.cardTypes, 't:')
            .map((e) => e.split('t:')[1])
            .toList();

    return cardTypes;
  }

  static String? _getRestOfQuery(List<String> splitQuery) {
    try {
      return splitQuery
          .where((element) => !element.contains(RegExp(r'[<>:=]')))
          .reduce((value, element) => '$value $element');
    } catch (e) {
      return null;
    }
  }

  static Future<void> startSearchForCard(
      BuildContext ctx,
      String text,
      List<String> languages,
      List<String> creatureTypes,
      List<String> keywordAbilities,
      List<String> cardTypes,
      MtGSet mtgSet,
      String cmcValue,
      String cmcCondition,
      Map<String, bool> manaSymbols) async {
    final cardDataProvider = Provider.of<CardDataProvider>(ctx, listen: false);
    final settings = Provider.of<Settings>(ctx, listen: false);
    // building all the necessary parameters for queries
    String languageQuery = languages.isNotEmpty
        ? languages.map((language) => "lang:$language").join(' ').trim()
        : '';
    String creatureTypesQuery = buildCumulativeQuery(creatureTypes, 't').trim();
    String cardTypesQuery = buildCumulativeQuery(cardTypes, 't').trim();
    String keywordAbilitiesQuery =
        buildCumulativeQuery(keywordAbilities, 'keyword').trim();
    String setQuery = mtgSet.code != '' ? "set:${mtgSet.code}" : '';
    String cmcQuery = cmcValue != '' ? "mv$cmcCondition$cmcValue" : '';
    String manaSymbolQuery = manaSymbols.isNotEmpty
        ? manaSymbols.entries
            .where((entry) => entry.value == true)
            .map((entry) => "m:${entry.key}")
            .join(' ')
        : '';
    // building full query list
    Map<String, dynamic> fullQueryList = {};
    fullQueryList.addEntries([
      MapEntry('text', text.isNotEmpty ? text : null),
      MapEntry('language', languageQuery.isNotEmpty ? languageQuery : null),
      MapEntry('creatureTypes',
          creatureTypesQuery.isNotEmpty ? creatureTypesQuery : null),
      MapEntry('cardTypes', cardTypesQuery.isNotEmpty ? cardTypesQuery : null),
      MapEntry('set', setQuery.isNotEmpty ? setQuery : null),
      MapEntry('cmc', cmcQuery.isNotEmpty ? cmcQuery : null),
      MapEntry(
          'manaSymbols', manaSymbolQuery.isNotEmpty ? manaSymbolQuery : null),
      MapEntry('keywordAbilities',
          keywordAbilitiesQuery.isNotEmpty ? keywordAbilitiesQuery : null),
    ]);
    // set query parameters in card data provider
    cardDataProvider.allQueryParameters = fullQueryList;
    cardDataProvider.query =
        fullQueryList.values.where((element) => element != null).join(' ');
    cardDataProvider.languages = languages;
    cardDataProvider.isStandardQuery = true;
    cardDataProvider.scryfallQueryMaps = ScryfallQueryMaps.searchMap;
    if (kDebugMode) {
      print('Using query: ${cardDataProvider.query}');
    }
    // handle query with built query parameters
    _handleQueryingOfData(ctx, cardDataProvider, settings);
  }

  static bool _postQueryFeedback(BuildContext ctx, String text, bool value) {
    if (!value) {
      showFailedQuery(ctx, text);
    }
    return value;
  }

  static void _handleQueryingOfData(BuildContext ctx,
      CardDataProvider cardDataProvider, Settings settings) async {
    final bool hasInternetConnection =
        await ConnectivityHelper.checkConnectivity();
    if (!hasInternetConnection || settings.useLocalDB) {
      await DBHelper.checkDatabaseSize(Constants.cardDatabaseTableFileName)
          .then((int dbSize) async {
        if (dbSize / 1024 ~/ 1024 > 3) {
          await cardDataProvider.processQueryLocally().then((value) {
            _postQueryFeedback(ctx, cardDataProvider.query, value);
            cardDataProvider.queryLocation = QueryLocation.local;
          });
        } else {
          _postQueryFeedback(ctx, cardDataProvider.query, false);
          cardDataProvider.queryLocation = QueryLocation.none;
        }
      });
    } else {
      if (kDebugMode) {
        print('using Scryfall API...');
      }
      await cardDataProvider.processQuery().then((value) {
        _postQueryFeedback(ctx, cardDataProvider.query, value);
        cardDataProvider.queryLocation = QueryLocation.scryfall;
      });
    }
  }
}
