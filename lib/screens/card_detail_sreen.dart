import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:magic_the_searching/providers/card_data_provider.dart';
import 'package:magic_the_searching/widgets/card_display.dart';
import '../models/card_data.dart';


class CardDetailScreen extends StatelessWidget {
  static const routeName = '/card-detail';

  const CardDetailScreen({Key? key}) : super(key: key);

  // final CardData cardData;

  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context)?.settings.arguments as String;
    final cardData = Provider.of<CardDataProvider>(context, listen: false).getCardById(id);
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(cardData.name),
      ),
      body: SizedBox(
        height: mediaQuery.size.height,
        child: Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image(image: AssetImage(cardData.image)),
              Text(cardData.name),
              Text(cardData.text),
            ],
          ),
        ),
      ),
    );
  }
}
