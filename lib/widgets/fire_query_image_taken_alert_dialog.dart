import 'package:flutter/material.dart';
import 'package:magic_the_searching/helpers/constants.dart';
import 'package:magic_the_searching/providers/history.dart';
import 'package:magic_the_searching/providers/image_taken_provider.dart';
import 'package:magic_the_searching/screens/card_search_screen.dart';
import 'package:provider/provider.dart';

import '../helpers/search_start_helper.dart';
import '../models/mtg_set.dart';

class FireQueryImageTakenAlertDialog extends StatelessWidget {
  const FireQueryImageTakenAlertDialog(
      this.cardName, this.cardType, this.creatureType, this.languages,
      {super.key});
  final String cardName;
  final List<String> cardType;
  final List<String> creatureType;
  final List<Languages> languages;

  @override
  Widget build(BuildContext context) {
    ImageTakenProvider imageTakenProvider =
        Provider.of<ImageTakenProvider>(context, listen: false);
    History historyProvider = Provider.of<History>(context, listen: false);
    return AlertDialog(
      title: const Text('Search for Card?'),
      titlePadding: const EdgeInsets.all(24.0),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32))),
      backgroundColor: Colors.blueGrey.shade200,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text('Name: $cardName'),
          const SizedBox(height: 8),
          Text(
              'Card Types: ${cardType.isNotEmpty ? cardType.reduce((value, element) => "$value $element") : ""}'),
          const SizedBox(height: 8),
          Text(
              'Creature Types: ${creatureType.isNotEmpty ? creatureType.reduce((value, element) => "$value $element") : ""}'),
          const SizedBox(
            height: 8,
          ),
          Text(
              'Detected Language: ${languages.isNotEmpty ? languages.fold("", (previousValue, element) => previousValue != "" ? "$previousValue ${element.longName}" : element.longName) : ""}')
        ],
      ),
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
            textStyle: Theme.of(context).textTheme.labelLarge,
          ),
          child: const Text('Yes'),
          onPressed: () {
            imageTakenProvider.openModalSheet = false;
            imageTakenProvider.cardName = cardName;
            imageTakenProvider.cardType = cardType;
            imageTakenProvider.creatureType = creatureType;
            historyProvider.openModalSheet = false;
            Navigator.of(context).pop();
            Navigator.of(context).popAndPushNamed(CardSearchScreen.routeName);
            SearchStartHelper.startSearchForCard(
              context,
              cardName,
              // languages,
              [Languages.en],
              creatureType,
              [],
              cardType,
              MtGSet.empty(),
              '',
              '',
              {},
            );
          },
        ),
        TextButton(
          style: TextButton.styleFrom(
            textStyle: Theme.of(context).textTheme.labelLarge,
          ),
          child: const Text('Fill in Search Mask'),
          onPressed: () {
            historyProvider.openModalSheet = false;
            imageTakenProvider.openModalSheet = true;
            imageTakenProvider.cardName = cardName;
            imageTakenProvider.cardType = cardType;
            imageTakenProvider.creatureType = creatureType;
            Navigator.of(context).pop();
            Navigator.of(context).popAndPushNamed(CardSearchScreen.routeName);
          },
        ),
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'))
      ],
    );
  }
}
