import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';

import '../helpers/card_symbol_helper.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchTermController = TextEditingController();
  final _creatureTypeController = TextEditingController();
  final _cardTypeController = TextEditingController();
  final _setController = TextEditingController();
  final _cmcValueController = TextEditingController();

  LanguageIdentifier languageIdentifier =
      LanguageIdentifier(confidenceThreshold: 0.5);

  List<String> _languages = [];

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
    // manaSymbols = _fetchManaSymbols();
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
    // return _languages;
  }

  // Future<List<Map<String, dynamic>>> _fetchManaSymbols() async {
  //   List<Map<String, dynamic>> symbols = [];
  //   List<String> manaSymbolPaths = await CardSymbolHelper.listAssetImages();

  //   for (var path in manaSymbolPaths) {
  //     for (var symbol in _manaSymbolsSelected.keys) {
  //       if (path.contains(symbol)) {
  //         symbols.add({
  //           'name': symbol,
  //         });
  //       }
  //     }
  //   }
  //   return symbols;
  // }

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
                TextFormField(
                  controller: _creatureTypeController,
                  decoration: const InputDecoration(labelText: 'Creature Type'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return null;
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _cardTypeController,
                  decoration: const InputDecoration(labelText: 'Card Type'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return null;
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _setController,
                  decoration: const InputDecoration(labelText: 'Set'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return null;
                    }
                    return null;
                  },
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
              'cardType': _cardTypeController.text,
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
