import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:magic_the_searching/helpers/constants.dart';
import 'package:magic_the_searching/providers/history.dart';
import 'package:magic_the_searching/providers/image_taken_provider.dart';
import 'package:magic_the_searching/providers/scryfall_provider.dart';
import 'package:provider/provider.dart';

import '../helpers/card_symbol_helper.dart';
import '../helpers/navigation_helper.dart';
import '../models/mtg_set.dart';

class FilterStateColor extends MaterialStateColor {
  const FilterStateColor() : super(0xcafefeed);

  static const Color _defaultColor = Color.fromRGBO(199, 195, 205, 1.0);

  static const Color _pressedColor = Color.fromRGBO(238, 249, 243, 1.0);

  @override
  Color resolve(Set<MaterialState> states) {
    if (states.contains(MaterialState.selected)) {
      return _pressedColor;
    }
    return _defaultColor;
  }
}

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

  final List<String> _languages = [];
  List<String> _selectedKeywordAbilities = [];
  List<String> _selectedCreatureTypes = [];
  List<String> _selectedCardTypes = [];

  final _setKey = GlobalKey<DropdownSearchState>();
  final _creatureTypeKey = GlobalKey<DropdownSearchState>();
  final _cardTypeKey = GlobalKey<DropdownSearchState>();
  final _keywordAbilitiesKey = GlobalKey<DropdownSearchState>();
  late FocusScopeNode _focusScopeNode;

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
    _focusScopeNode = FocusScopeNode(canRequestFocus: true);

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
            widget.prefilledValues![Constants.contextSet]?.code ?? '';
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

  @override
  void dispose() {
    super.dispose();
    _focusScopeNode.dispose();
  }

  Widget _getManaSymbolsField() {
    return Container(
      color: Colors.transparent,
      width: MediaQuery.of(context).size.width - 32,
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        children: _manaSymbolsSelected.entries.map((entry) {
          return FilterChip(
            backgroundColor: Colors.transparent,
            color: const FilterStateColor(),
            shape: const CircleBorder(
                side: BorderSide(
                    color: Colors.black, width: 2, style: BorderStyle.solid),
                eccentricity: 0),
            showCheckmark: false,
            label: SvgPicture.asset(
              CardSymbolHelper.symbolToAssetPath(entry.key),
              width: 42,
              height: 42,
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
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
      key: _setKey,
      initialValue: TextEditingValue(
          text: widget.prefilledValues?[Constants.contextSet]?.name ?? ''),
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
        if (kDebugMode) {
          print('Setting setcontroller text to: ${selection.code}');
        }
        setState(() {
          _setController.text = selection.code;
        });
      },
      fieldViewBuilder: (BuildContext context,
          TextEditingController fieldTextEditingController,
          FocusNode fieldFocusNode,
          VoidCallback onFieldSubmitted) {
        return TextFormField(
          textInputAction: TextInputAction.next,
          controller: fieldTextEditingController,
          decoration: const InputDecoration(labelText: 'Set'),
          focusNode: fieldFocusNode,
          onFieldSubmitted: (String value) {
            _creatureTypeKey.currentState?.openDropDownSearch();
          },
        );
      },
      displayStringForOption: (MtGSet option) => option.name,
    );
  }

  TextFormField _getSearchTermField() {
    return TextFormField(
      autofocus: true,
      onFieldSubmitted: (value) {
        if (_setKey.currentState != null) {
          _setKey.currentState!.openDropDownSearch();
        }
      },
      textInputAction: TextInputAction.next,
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
      Function(List<String>, String) onSelectionChanged,
      List<String> selectedObjectItems,
      List<String> options,
      TextEditingController textEditingController,
      String label,
      GlobalKey key) {
    return DropdownSearch<String>.multiSelection(
      key: key,
      items: options,
      onSaved: (newValue) {
        if (kDebugMode) {
          print('Multi selection on saved: $newValue');
        }
      },
      onChanged: (value) {
        onSelectionChanged(value, '');
      },
      dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(labelText: label)),
      popupProps: PopupPropsMultiSelection.menu(
        showSearchBox: true,
        searchDelay: Duration.zero,
        onItemAdded: onSelectionChanged,
        onItemRemoved: onSelectionChanged,
        searchFieldProps: TextFieldProps(
            autofocus: true,
            textInputAction: TextInputAction.next,
            controller: textEditingController),
        showSelectedItems: true,
      ),
      selectedItems: selectedObjectItems,
    );
  }

  @override
  Widget build(BuildContext context) {
    ScryfallProvider scryfallProvider =
        Provider.of<ScryfallProvider>(context, listen: true);
    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvoked: (didPop) {
        if (didPop) {
          Provider.of<History>(context, listen: false).openModalSheet = false;
          Provider.of<ImageTakenProvider>(context, listen: false)
              .openModalSheet = false;
          return;
        }
        if (!Navigator.canPop(context)) {
          NavigationHelper.showExitAppDialog(context);
        }
      },
      child: Container(
        alignment: Alignment.topLeft,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.bottomRight,
            stops: [0.1, 0.9],
            colors: [
              Color.fromRGBO(199, 195, 205, 1.0),
              Color.fromRGBO(218, 229, 223, 1.0),
            ],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: const Text('Search'),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: FocusScope(
                  node: _focusScopeNode,
                  canRequestFocus: true,
                  skipTraversal: false,
                  child: Column(
                    children: [
                      _getSearchTermField(),
                      _getMtgSetField(scryfallProvider.sets),
                      // Creature Types
                      _getMultiDropdownSelectionField((p0, p1) {
                        setState(() {
                          _selectedCreatureTypes = p0;
                        });
                      },
                          _selectedCreatureTypes,
                          scryfallProvider.creatureTypes,
                          _creatureTypesTextController,
                          'Creature Types',
                          _creatureTypeKey),
                      // Card Types
                      _getMultiDropdownSelectionField((p0, p1) {
                        setState(() {
                          _selectedCardTypes = p0;
                        });
                      }, _selectedCardTypes, scryfallProvider.cardTypes,
                          _cardTypesTextController, 'Card Types', _cardTypeKey),
                      // Keyword Abilities
                      _getMultiDropdownSelectionField((p0, p1) {
                        setState(() {
                          _selectedKeywordAbilities = p0;
                        });
                      },
                          _selectedKeywordAbilities,
                          scryfallProvider.keywordAbilities,
                          _keywordAbilitiesTextController,
                          'Keyword Abilities',
                          _keywordAbilitiesKey),
                      _getCmcField(),
                      const SizedBox(
                        height: 8,
                      ),
                      _getManaSymbolsField(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                MtGSet? set = scryfallProvider.sets
                    .where((element) => element.code == _setController.text)
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
        ),
      ),
    );
  }
}
