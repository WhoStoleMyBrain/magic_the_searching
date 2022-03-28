import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class EnterSearchTerm extends StatefulWidget {
  final Function startSearchForCard;
  const EnterSearchTerm({Key? key, required this.startSearchForCard})
      : super(key: key);
  @override
  State<EnterSearchTerm> createState() => _EnterSearchTermState();
}

class _EnterSearchTermState extends State<EnterSearchTerm> {
  final _searchTermController = TextEditingController();
  LanguageIdentifier languageIdentifier = GoogleMlKit.nlp.languageIdentifier();

  void _submitSearchText() async {
    if (_searchTermController.text.isEmpty) {
      // print('search term controller is empty');
      // print(_searchTermController.text);
      return;
    }
    final List<String> languages = [];
    final String searchTerm = _searchTermController.text;
    // print('submitting...; ${_searchTermController.text}');
    try {
      final String response =
          await languageIdentifier.identifyLanguage(searchTerm);
      // print('lang: $response; text: $searchTerm');
      languages.add(response);
    } on PlatformException catch (pe) {
      if (pe.code == languageIdentifier.errorCodeNoLanguageIdentified) {
        // no language detected
        languages.add('');
        // print('no languages detected');
      }
      languages.add('');
    }
    if (!languages.contains('en')) {
      languages.add('en');
    }
    widget.startSearchForCard(searchTerm, languages);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        child: Container(
          padding: EdgeInsets.only(
              top: 10,
              left: 10,
              right: 10,
              bottom: MediaQuery.of(context).viewInsets.bottom + 10),
          child: Column(
            children: [
              TextField(
                enableSuggestions: false,
                decoration:
                    const InputDecoration(labelText: 'Name of the card'),
                controller: _searchTermController,
                onSubmitted: (_) => _submitSearchText(),
                autofocus: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
