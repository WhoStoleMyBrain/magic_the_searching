import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:magic_the_searching/helpers/constants.dart';
import 'package:magic_the_searching/providers/scryfall_provider.dart';
import 'package:provider/provider.dart';

import '../helpers/card_symbol_helper.dart';
import '../models/mtg_set.dart';

class SearchPage extends StatefulWidget {
  final Map<String, dynamic>? prefilledValues;
  const SearchPage({super.key, this.prefilledValues});

  @override
  State<SearchPage> createState() => _SearchPageState();
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
  List<String> _selectedKeywordAbilities = [];
  List<String> _selectedCreatureTypes = [];
  List<String> _selectedCardTypes = [];

  String _selectedCmcCondition = '<';
  Map<String, bool> _manaSymbolsSelected = {
    'G': false,
    'R': false,
    'B': false,
    'U': false,
    'W': false,
  };

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    setState(() {
      if (widget.prefilledValues != null) {
        _searchTermController.text =
            widget.prefilledValues![Constants.contextSearchTerm] ?? '';
        _selectedCreatureTypes =
            widget.prefilledValues![Constants.contextCreatureTypes] ?? [];
        _selectedCardTypes =
            widget.prefilledValues![Constants.contextCardTypes] ?? [];
        _selectedKeywordAbilities =
            widget.prefilledValues![Constants.contextKeywords] ?? [];

        _setController.text =
            widget.prefilledValues![Constants.contextSet]?.name ?? '';
        _cmcValueController.text =
            widget.prefilledValues![Constants.contextCmcValue] ?? '';
        _selectedCmcCondition =
            widget.prefilledValues![Constants.contextCmcCondition] ?? '<';
        _manaSymbolsSelected =
            widget.prefilledValues![Constants.contextManaSymbols] ??
                _manaSymbolsSelected;
      }
    });
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
        // const Text('Colors:'),
        Wrap(
          spacing: 8.0,
          children: _manaSymbolsSelected.entries.map((entry) {
            return FilterChip(
              shape: const CircleBorder(
                  side: BorderSide(
                      color: Colors.black, width: 2, style: BorderStyle.solid),
                  eccentricity: 0),
              showCheckmark: false,
              label: SvgPicture.asset(
                CardSymbolHelper.symbolToAssetPath(entry.key),
                // width: 24,
                // height: 24,
                width: 36,
                height: 36,
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

  Autocomplete<MtGSet> _getMtgSetField(List<MtGSet> sets) {
    return Autocomplete<MtGSet>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return const Iterable<MtGSet>.empty();
        }
        return sets.where((MtGSet option) {
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
    ScryfallProvider scryfallProvider =
        Provider.of<ScryfallProvider>(context, listen: true);
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
                }, _selectedCreatureTypes, scryfallProvider.creatureTypes,
                    _creatureTypesTextController, 'Creature Types'),
                _getMultiDropdownSelectionField((p0, p1) {
                  setState(() {
                    _selectedCardTypes = p0;
                  });
                }, _selectedCardTypes, scryfallProvider.cardTypes,
                    _cardTypesTextController, 'Card Types'),
                _getMultiDropdownSelectionField((p0, p1) {
                  setState(() {
                    _selectedKeywordAbilities = p0;
                  });
                }, _selectedKeywordAbilities, scryfallProvider.keywordAbilities,
                    _keywordAbilitiesTextController, 'Keyword Abilities'),
                _getMtgSetField(scryfallProvider.sets),
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
            MtGSet? set = scryfallProvider.sets
                .where((element) => element.name == _setController.text)
                .firstOrNull;
            Navigator.pop(context, {
              Constants.contextSearchTerm: _searchTermController.text,
              Constants.contextLanguages: _languages,
              Constants.contextCreatureTypes: _selectedCreatureTypes
                  .map((e) => scryfallProvider.mappedCreatureTypes[e]!)
                  .toList(),
              Constants.contextCardTypes: _selectedCardTypes,
              Constants.contextKeywords: _selectedKeywordAbilities
                  .map((e) => scryfallProvider.mappedKeywordAbilities[e]!)
                  .toList(),
              Constants.contextSet: set ?? MtGSet.empty(),
              Constants.contextCmcValue: _cmcValueController.text,
              Constants.contextCmcCondition: _selectedCmcCondition,
              Constants.contextManaSymbols: _manaSymbolsSelected,
            });
          }
        },
        child: const Icon(Icons.search),
      ),
    );
  }
}
