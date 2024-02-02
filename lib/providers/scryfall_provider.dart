import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../helpers/constants.dart';
import '../models/mtg_set.dart';

class ScryfallProvider with ChangeNotifier {
  final _cacheManager = DefaultCacheManager();

  List<String> get cardTypes => [
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
        'Legendary',
      ];

  List<String> _creatureTypes = [];
  List<String> _keywordAbilities = [];
  List<MtGSet> _sets = [];

  Map<String, String> _mappedCreatureTypes = {};
  Map<String, String> _mappedKeywordAbilities = {};

  List<String> get creatureTypes => _creatureTypes;
  List<String> get keywordAbilities => _keywordAbilities;
  Map<String, String> get mappedCreatureTypes => _mappedCreatureTypes;
  Map<String, String> get mappedKeywordAbilities => _mappedKeywordAbilities;
  List<MtGSet> get sets => _sets;

  Future<List<String>> _fetchTypesFromUrl(String url) async {
    final response = await _cacheManager.getSingleFile(url);
    final Map<String, dynamic> jsonData =
        jsonDecode(await response.readAsString());
    if (jsonData.containsKey('data')) {
      return List<String>.from(jsonData['data']);
    }
    return [];
  }

  void init() async {
    _fetchCreatureTypes();
    _fetchKeywordAbilities();
    _fetchSets();
  }

  void _fetchCreatureTypes() async {
    try {
      _creatureTypes = await _fetchTypesFromUrl(Constants.urlCreatureTypes);
      _mappedCreatureTypes = _creatureTypes
          .asMap()
          .map((key, value) => MapEntry(value, value.replaceAll(' ', '-')));
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching creature types: $e');
      }
    }
  }

  void _fetchKeywordAbilities() async {
    try {
      _keywordAbilities =
          await _fetchTypesFromUrl(Constants.urlKeywordAbilities);
      _mappedKeywordAbilities = _keywordAbilities
          .asMap()
          .map((key, value) => MapEntry(value, value.replaceAll(' ', '-')));
      _mappedKeywordAbilities =
          Map.fromEntries(_mappedKeywordAbilities.entries.toList()
            ..sort(
              (a, b) => a.value.compareTo(b.value),
            ));
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching creature types: $e');
      }
    }
  }

  void _fetchSets() async {
    const url = Constants.urlSets;
    try {
      final response = await _cacheManager.getSingleFile(url);
      final Map<String, dynamic> jsonData =
          jsonDecode(await response.readAsString());

      if (jsonData.containsKey('data')) {
        _sets = jsonData['data']
            .map<MtGSet>((json) => MtGSet(
                  code: json['code'],
                  name: json['name'],
                  releasedAt: json['released_at'] != null
                      ? DateTime.parse(json['released_at'])
                      : null,
                  iconSvgUri: json['icon_svg_uri'],
                ))
            .toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching sets: $e');
      }
    }
  }
}
