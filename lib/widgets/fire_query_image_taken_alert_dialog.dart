import 'package:flutter/material.dart';
import 'package:magic_the_searching/providers/history.dart';
import 'package:magic_the_searching/providers/image_taken_provider.dart';
import 'package:magic_the_searching/screens/card_search_screen.dart';
import 'package:provider/provider.dart';

import '../helpers/search_start_helper.dart';
import '../models/mtg_set.dart';

class FireQueryImageTakenAlertDialog extends StatelessWidget {
  const FireQueryImageTakenAlertDialog(
      this.cardName, this.cardType, this.creatureType,
      {super.key});
  final String cardName;
  final List<String> cardType;
  final List<String> creatureType;

  @override
  Widget build(BuildContext context) {
    ImageTakenProvider imageTakenProvider =
        Provider.of<ImageTakenProvider>(context, listen: false);
    History historyProvider = Provider.of<History>(context, listen: false);
    return AlertDialog(
      title: const Text('Search for Card?'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text('Name: $cardName'),
          ...[
            Text(
                'Card Types: ${cardType.isNotEmpty ? cardType.reduce((value, element) => "$value $element") : ""}'),
            Text(
                'Creature Types: ${creatureType.isNotEmpty ? creatureType.reduce((value, element) => "$value $element") : ""}')
          ]
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
            Navigator.of(context).pushNamed(CardSearchScreen.routeName);
            SearchStartHelper.startSearchForCard(
              context,
              cardName,
              // languages,
              ['en'],
              creatureType,
              [],
              cardType,
              MtGSet.empty(),
              '',
              '',
              {},
            );
            // Navigator.pop(context);
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
            Navigator.of(context).pushNamed(CardSearchScreen.routeName);
            // SystemChannels.platform.invokeMethod('SystemNavigator.pop');
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
