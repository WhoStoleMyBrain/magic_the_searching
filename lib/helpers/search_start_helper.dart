import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:magic_the_searching/helpers/scryfall_query_maps.dart';
import 'package:magic_the_searching/models/mtg_set.dart';
import 'package:magic_the_searching/providers/scryfall_provider.dart';
import 'package:provider/provider.dart';

import '../providers/card_data_provider.dart';
import '../providers/history.dart';
import '../providers/settings.dart';
import '../widgets/enter_search_term.dart';
import 'constants.dart';

class SearchStartHelper {
  static final SearchStartHelper _searchStartHelper =
      SearchStartHelper._internal();
  factory SearchStartHelper() {
    return _searchStartHelper;
  }
  SearchStartHelper._internal();
  static String prefillValue = '';

  static void startEnterSearchTerm(
    BuildContext ctx,
  ) {
    showModalBottomSheet(
      context: ctx,
      builder: (bCtx) {
        return GestureDetector(
          onTap: () {},
          child: EnterSearchTerm(
            prefillValue: prefillValue,
            startSearchForCard: (text, languages) {
              return SearchStartHelper.startSearchForCard(
                ctx,
                text,
                languages,
                [],
                [],
                [],
                MtGSet.empty(),
                '',
                '',
                {},
              );
            },
          ),
        );
      },
    ).whenComplete(() {
      SearchStartHelper.prefillValue = '';
      final history = Provider.of<History>(ctx, listen: false);
      history.openModalSheet = false;
    });
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
    print('splitQuery: ${splitQuery.asMap()}');
    // fetching the correct parts of the split query
    var sets = _getItemsWithStringStart(splitQuery, 'e:');
    var manaValues = _getItemsWithStringStart(splitQuery, 'mv');
    var manaSymbols = _getItemsWithStringStart(splitQuery, 'm:');
    var keywords = splitQuery.where((element) => element.contains('keyword:'));
    var types = splitQuery.where((element) => element.contains('t:'));

    // fetch set
    var foundSet = scryfallProvider.sets
        .where((element) => sets.contains(element.name))
        .toList()
        .firstOrNull;

    // fetch cmc value
    var foundCmcValues = manaValues.isNotEmpty ? manaValues.first : '';
    var conditionRegExp = RegExp(r'[<|>|<=|>=|=]');
    var numberRegExp = RegExp(r'\d');
    var condition = conditionRegExp.firstMatch(foundCmcValues)?[0];
    var number = numberRegExp.firstMatch(foundCmcValues)?[0];

    // fetch colors
    List<String> colors = ['W', 'U', 'B', 'R', 'G'];
    Map<String, bool> mappedManaSymbols = colors.asMap().map(
          (key, value) => MapEntry(value, manaSymbols.contains(value)),
        );

    // fetch rest of the query
    var restOfQuery = splitQuery
        .where((element) => !element.contains(RegExp(r'[<>:=]')))
        .reduce((value, element) => '$value $element');

    var cardTypes = types
        .where((element) =>
            scryfallProvider.cardTypes.contains(element.split('t:')[1]))
        .map((e) => e.split('t:')[1])
        .toList();
    // fetch creature types
    var creatureTypes = types
        .where((element) => scryfallProvider.mappedCreatureTypes.values
            .contains(element.split('t:')[1]))
        .toList();
    creatureTypes = creatureTypes
        .map(
          (e) => scryfallProvider.mappedCreatureTypes
              .map((key, value) => MapEntry(value, key))[e.split('t:')[1]]!,
        )
        .toList();
    // fetch keywords
    List<String>? foundKeywords;
    try {
      foundKeywords = keywords
          .map((e) => scryfallProvider.mappedKeywordAbilities.map(
              (key, value) => MapEntry(value, key))[e.split('keyword:')[1]]!)
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Unhandled error: $e');
      }
      foundKeywords = null;
    }

    return {
      Constants.contextCreatureTypes: creatureTypes,
      Constants.contextKeywords: foundKeywords,
      Constants.contextCardTypes: cardTypes,
      Constants.contextSet: foundSet,
      Constants.contextManaSymbols: mappedManaSymbols,
      Constants.contextSearchTerm: restOfQuery,
      Constants.contextCmcCondition: condition,
      Constants.contextCmcValue: number,
    };
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
    // print(
    //     'creature types: $creatureTypes; keywordAbilities: $keywordAbilities, cardtypes: $cardTypes');
    final cardDataProvider = Provider.of<CardDataProvider>(ctx, listen: false);
    final settings = Provider.of<Settings>(ctx, listen: false);
    bool requestSuccessful;

    String languageQuery = languages.isNotEmpty
        ? languages.map((language) => "lang:$language").join(' ').trim()
        : '';
    String creatureTypesQuery = buildCumulativeQuery(creatureTypes, 't').trim();
    String cardTypesQuery = buildCumulativeQuery(cardTypes, 't').trim();
    String keywordAbilitiesQuery =
        buildCumulativeQuery(keywordAbilities, 'keyword').trim();
    String setQuery = mtgSet.name.isEmpty ? "e:${mtgSet.name}" : '';
    String cmcQuery = cmcValue != ''
        ? "mv$cmcCondition$cmcValue"
        : ''; //TODO Fix this != 0 part
    String manaSymbolQuery = manaSymbols.isNotEmpty
        ? manaSymbols.entries
            .where((entry) => entry.value == true)
            .map((entry) => "m:${entry.key}")
            .join(' ')
        : '';
    var fullQueryList = [];
    text.isNotEmpty ? fullQueryList.add(text) : null;
    languageQuery.isNotEmpty ? fullQueryList.add(languageQuery) : null;
    creatureTypesQuery.isNotEmpty
        ? fullQueryList.add(creatureTypesQuery)
        : null;
    cardTypesQuery.isNotEmpty ? fullQueryList.add(cardTypesQuery) : null;
    setQuery.isNotEmpty ? fullQueryList.add(setQuery) : null;
    cmcQuery.isNotEmpty ? fullQueryList.add(cmcQuery) : null;
    manaSymbolQuery.isNotEmpty ? fullQueryList.add(manaSymbolQuery) : null;
    keywordAbilitiesQuery.isNotEmpty
        ? fullQueryList.add(keywordAbilitiesQuery)
        : null;
    // cardDataProvider.query =
    //     "$text $languageQuery $creatureTypesQuery $cardTypesQuery $setQuery $cmcQuery $manaSymbolQuery $keywordAbilitiesQuery"
    //         .trim();
    cardDataProvider.query = fullQueryList.join(' ');
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
