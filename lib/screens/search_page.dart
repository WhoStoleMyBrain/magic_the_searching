import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';

import '../helpers/card_symbol_helper.dart';
import '../models/mtg_set.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchTermController = TextEditingController();
  final _creatureTypeController = TextEditingController();
  // final _cardTypeController = TextEditingController();
  final _setController = TextEditingController();
  final _cmcValueController = TextEditingController();

  LanguageIdentifier languageIdentifier =
      LanguageIdentifier(confidenceThreshold: 0.5);

  List<String> _languages = [];
  List<String> _creatureTypes = [];
  List<MtGSet> _sets = [];
  final _cacheManager = DefaultCacheManager();

  String _selectedCmcCondition = '<';
  final Map<String, bool> _manaSymbolsSelected = {
    'G': false,
    'R': false,
    'B': false,
    'U': false,
    'W': false,
  };

  final _formKey = GlobalKey<FormState>();

  // Future<List<Map<String, dynamic>>> manaSymbols = Future.value([]);

  @override
  void initState() {
    super.initState();
    _fetchCreatureTypes();
    _fetchSets();
  }

  void _fetchCreatureTypes() async {
    const url = 'https://api.scryfall.com/catalog/creature-types';
    try {
      final response = await _cacheManager.getSingleFile(url);
      final Map<String, dynamic> jsonData =
          jsonDecode(await response.readAsString());

      if (jsonData.containsKey('data')) {
        _creatureTypes = List<String>.from(jsonData['data']);
      }
    } catch (e) {
      print('Error fetching creature types: $e');
    }
  }

  void _fetchSets() async {
    final url = 'https://api.scryfall.com/sets';
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
      print('Error fetching sets: $e');
    }
  }

  void _identifyLanguages(String _) async {
    if (_searchTermController.text.isEmpty) {
      return;
    }
    _languages = [];
    final String searchTerm = _searchTermController.text;

    try {
      final String response =
          await languageIdentifier.identifyLanguage(searchTerm);
      _languages.add(response);
    } on PlatformException catch (pe) {
      if (pe.code == languageIdentifier.undeterminedLanguageCode) {
        _languages.add('');
      }
      _languages.add('');
    }
    if (!_languages.contains('en')) {
      _languages.add('en');
    }
  }

  String? _selectedCardType; // Initial default value

  // The card types
  final List<String> _cardTypes = [
    'None',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _searchTermController,
                  onChanged: _identifyLanguages,
                  decoration:
                      const InputDecoration(labelText: 'Name of the card'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return null;
                    }
                    return null;
                  },
                ),
                Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text == '') {
                      return const Iterable<String>.empty();
                    }
                    return _creatureTypes.where((String option) {
                      return option
                          .toLowerCase()
                          .contains(textEditingValue.text.toLowerCase());
                    });
                  },
                  onSelected: (String selection) {
                    _creatureTypeController.text = selection;
                  },
                  fieldViewBuilder: (BuildContext context,
                      TextEditingController fieldTextEditingController,
                      FocusNode fieldFocusNode,
                      VoidCallback onFieldSubmitted) {
                    return TextFormField(
                      controller: fieldTextEditingController,
                      decoration:
                          const InputDecoration(labelText: 'Creature Type'),
                      focusNode: fieldFocusNode,
                      onFieldSubmitted: (String value) {
                        onFieldSubmitted();
                      },
                    );
                  },
                ),
                Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text == '') {
                      return const Iterable<String>.empty();
                    }
                    return _cardTypes.where((String option) {
                      return option
                          .toLowerCase()
                          .contains(textEditingValue.text.toLowerCase());
                    });
                  },
                  onSelected: (String selection) {
                    setState(() {
                      _selectedCardType = selection;
                    });
                  },
                  fieldViewBuilder: (BuildContext context,
                      TextEditingController fieldTextEditingController,
                      FocusNode fieldFocusNode,
                      VoidCallback onFieldSubmitted) {
                    return TextFormField(
                      controller: fieldTextEditingController,
                      decoration: const InputDecoration(labelText: 'Card Type'),
                      focusNode: fieldFocusNode,
                      onFieldSubmitted: (String value) {
                        onFieldSubmitted();
                      },
                    );
                  },
                ),
                Autocomplete<MtGSet>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text == '') {
                      return const Iterable<MtGSet>.empty();
                    }
                    return _sets.where((MtGSet option) {
                      return option.name
                          .toLowerCase()
                          .contains(textEditingValue.text.toLowerCase());
                    });
                  },
                  onSelected: (MtGSet selection) {
                    _setController.text = selection.code;
                  },
                  fieldViewBuilder: (BuildContext context,
                      TextEditingController fieldTextEditingController,
                      FocusNode fieldFocusNode,
                      VoidCallback onFieldSubmitted) {
                    return TextFormField(
                      controller: fieldTextEditingController,
                      decoration: const InputDecoration(labelText: 'Set'),
                      focusNode: fieldFocusNode,
                      onFieldSubmitted: (String value) {
                        onFieldSubmitted();
                      },
                    );
                  },
                  displayStringForOption: (MtGSet option) => option.name,
                ),
                Row(
                  children: [
                    DropdownButton<String>(
                      value: _selectedCmcCondition,
                      items: <String>[
                        '<',
                        '<=',
                        '=',
                        '>',
                        '>=',
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCmcCondition = newValue!;
                        });
                      },
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: _cmcValueController,
                        decoration:
                            const InputDecoration(labelText: 'CMC Value'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return null;
                          } else if (double.tryParse(value) == null) {
                            return 'Please enter a valid number.';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text('Colors:'),
                    Wrap(
                      spacing: 8.0,
                      children: _manaSymbolsSelected.entries.map((entry) {
                        return FilterChip(
                          label: SvgPicture.asset(
                            CardSymbolHelper.symbolToAssetPath(entry.key),
                            width: 24,
                            height: 24,
                          ),
                          labelPadding: EdgeInsets.zero,
                          selected: entry.value,
                          onSelected: (bool selected) {
                            setState(() {
                              _manaSymbolsSelected[entry.key] = selected;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            Navigator.pop(context, {
              'searchTerm': _searchTermController.text,
              'languages': _languages,
              'creatureType': _creatureTypeController.text,
              'cardType': _selectedCardType,
              'set': _setController.text,
              'cmcValue': _cmcValueController.text,
              'cmcCondition': _selectedCmcCondition,
              'colors': _manaSymbolsSelected,
            });
          }
        },
        child: const Icon(Icons.search),
      ),
    );
  }
}
