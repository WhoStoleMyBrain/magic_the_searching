import 'package:flutter/material.dart';

class EnterSearchTerm extends StatefulWidget {

  final Function startSearchForCard;
  const EnterSearchTerm({Key? key, required this.startSearchForCard}) : super(key: key);
  @override
  State<EnterSearchTerm> createState() => _EnterSearchTermState();
}

class _EnterSearchTermState extends State<EnterSearchTerm> {
  final _searchTermController = TextEditingController();

  void _submitSearchText() {
    if (_searchTermController.text.isEmpty) {
      return;
    }
    widget.startSearchForCard(_searchTermController.text);
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
                decoration: const InputDecoration(labelText: 'Name of the card'),
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
