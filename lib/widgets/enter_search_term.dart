import 'package:flutter/material.dart';

class EnterSearchTerm extends StatelessWidget {
  EnterSearchTerm({Key? key}) : super(key: key);

  final _searchTermController = TextEditingController();

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
                onSubmitted: null,
                autofocus: true,
              )
            ],
          ),
        ),
      ),
    );
  }
}
