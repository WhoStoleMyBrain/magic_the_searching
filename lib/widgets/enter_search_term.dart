// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';

class EnterSearchTerm extends StatefulWidget {
  final Function startSearchForCard;
  final String prefillValue;
  const EnterSearchTerm(
      {super.key, required this.startSearchForCard, this.prefillValue = ''});
  @override
  State<EnterSearchTerm> createState() => _EnterSearchTermState();
}

class _EnterSearchTermState extends State<EnterSearchTerm> {
  final _searchTermController = TextEditingController();
  LanguageIdentifier languageIdentifier =
      LanguageIdentifier(confidenceThreshold: 0.5);

  @override
  void initState() {
    super.initState();
    _searchTermController.text = widget.prefillValue;
  }

  @override
  void dispose() {
    super.dispose();
    _searchTermController.dispose();
  }

  void _submitSearchText() async {
    if (_searchTermController.text.isEmpty) {
      return;
    }
    final List<String> languages = [];
    final String searchTerm = _searchTermController.text;
    try {
      final String response =
          await languageIdentifier.identifyLanguage(searchTerm);
      languages.add(response);
    } on PlatformException catch (pe) {
      if (pe.code == languageIdentifier.undeterminedLanguageCode) {
        // no language detected
        languages.add('');
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
