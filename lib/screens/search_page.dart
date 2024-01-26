import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:magic_the_searching/helpers/constants.dart';

import '../helpers/card_symbol_helper.dart';
import '../models/mtg_set.dart';

class SearchPage extends StatefulWidget {
  final Map<String, dynamic>? prefilledValues;
  const SearchPage({super.key, this.prefilledValues});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchTermController = TextEditingController();

  final TextEditingController _keywordAbilitiesTextController =
      TextEditingController();
  final _creatureTypesTextController = TextEditingController();
  final _cardTypesTextController = TextEditingController();
  final TextEditingController _setController = TextEditingController();
  final TextEditingController _cmcValueController = TextEditingController();

  LanguageIdentifier languageIdentifier =
      LanguageIdentifier(confidenceThreshold: 0.5);

  List<String> _languages = [];
  List<String> _creatureTypes = [];
  List<MtGSet> _sets = [];
  List<String> _selectedKeywordAbilities = [];
  List<String> _keywordAbilities = [];
  List<String> _selectedCreatureTypes = [];
  List<String> _selectedCardTypes = [];
  final _cacheManager = DefaultCacheManager();

  String _selectedCmcCondition = '<';
  Map<String, bool> _manaSymbolsSelected = {
    'G': false,
    'R': false,
    'B': false,
    'U': false,
    'W': false,
  };

  // The card types
  final List<String> _cardTypes = [
    // 'None',
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

  final _formKey = GlobalKey<FormState>();

  // Future<List<Map<String, dynamic>>> manaSymbols = Future.value([]);

  @override
  void initState() {
    super.initState();
    _fetchCreatureTypes();
    _fetchSets();
    _fetchKeywordAbilities();
    setState(() {
      if (widget.prefilledValues != null) {
        _searchTermController.text =
            widget.prefilledValues!['searchTerm'] ?? '';
        _creatureTypes = widget.prefilledValues!['creatureTypes'] ?? [];
        _selectedCardTypes = widget.prefilledValues!['selectedCardTypes'] ?? [];
        _selectedKeywordAbilities =
            widget.prefilledValues!['selectedKeywordAbilities'] ?? [];

        _setController.text = widget.prefilledValues!['set'] ?? '';
        _cmcValueController.text = widget.prefilledValues!['cmcValue'] ?? '';
        _selectedCmcCondition = widget.prefilledValues!['cmcCondition'] ?? '<';
        _manaSymbolsSelected =
            widget.prefilledValues!['colors'] ?? _manaSymbolsSelected;
      }
    });
  }

  Future<List<String>> _fetchTypesFromUrl(String url) async {
    final response = await _cacheManager.getSingleFile(url);
    final Map<String, dynamic> jsonData =
        jsonDecode(await response.readAsString());
    if (jsonData.containsKey('data')) {
      return List<String>.from(jsonData['data']);
    }
    return [];
  }

  void _fetchCreatureTypes() async {
    try {
      _creatureTypes = await _fetchTypesFromUrl(Constants.urlCreatureTypes);
      setState(() {});
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
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching creature types: $e');
      }
    }
  }

  void _fetchSets() async {
    const url = 'https://api.scryfall.com/sets';
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

  Row _getManaSymbolsField() {
    return Row(
      children: [
        const Text('Colors:'),
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
    );
  }

  Row _getCmcField() {
    return Row(
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
            decoration: const InputDecoration(labelText: 'CMC Value'),
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
    );
  }

  Autocomplete<MtGSet> _getMtgSetField() {
    return Autocomplete<MtGSet>(
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
        fieldTextEditingController.text = _setController.text;
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
    );
  }

  TextFormField _getSearchTermField() {
    return TextFormField(
      controller: _searchTermController,
      decoration: InputDecoration(
        labelText: 'Name of the card',
        suffixIcon: _searchTermController.text.isEmpty
            ? null
            : IconButton(
                onPressed: () => setState(() => _searchTermController.clear()),
                icon: const Icon(Icons.clear, color: Colors.red),
              ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return null;
        }
        return null;
      },
    );
  }

  Widget _getMultiDropdownSelectionField(
      Function(List<String>, String)? onSelectionChanged,
      List<String> selectedObjectItems,
      List<String> options,
      TextEditingController textEditingController,
      String label) {
    return DropdownSearch<String>.multiSelection(
      items: options,
      dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(labelText: label)),
      popupProps: PopupPropsMultiSelection.menu(
        showSearchBox: true,
        searchDelay: Duration.zero,
        onItemAdded: (selectedItems, addedItem) {
          onSelectionChanged!(selectedItems, addedItem);
        },
        onItemRemoved: onSelectionChanged,
        searchFieldProps: TextFieldProps(
            onTap: () {},
            controller: textEditingController,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  textEditingController.clear();
                },
              ),
            )),
        showSelectedItems: true,
      ),
      selectedItems: selectedObjectItems,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _getSearchTermField(),
                _getMultiDropdownSelectionField((p0, p1) {
                  setState(() {
                    _selectedCreatureTypes = p0;
                  });
                }, _selectedCreatureTypes, _creatureTypes,
                    _creatureTypesTextController, 'Creature Types'),
                _getMultiDropdownSelectionField((p0, p1) {
                  setState(() {
                    _selectedCardTypes = p0;
                  });
                }, _selectedCardTypes, _cardTypes, _cardTypesTextController,
                    'Card Types'),
                _getMultiDropdownSelectionField((p0, p1) {
                  setState(() {
                    _selectedKeywordAbilities = p0;
                  });
                }, _selectedKeywordAbilities, _keywordAbilities,
                    _keywordAbilitiesTextController, 'Keyword Abilities'),
                _getMtgSetField(),
                _getCmcField(),
                _getManaSymbolsField(),
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
              'creatureTypes': _selectedCreatureTypes,
              'cardTypes': _selectedCardTypes,
              'keywordAbilities': _selectedKeywordAbilities,
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
