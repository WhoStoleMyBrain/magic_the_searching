import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:magic_the_searching/providers/card_data_provider.dart';


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
              cardData.images[0].contains('http')
                  ? Image.network(cardData.images[0], fit: BoxFit.cover)
                  : Image(image: AssetImage(cardData.images[0])),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Normal'),
                        Text('Foil'),
                      ],
                    ),
                    const Divider(color: Colors.black, thickness: 1,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // cardData.price.forEach((key, value) {Text('$key:$value')})
                        // cardData.price.map((key, value) => Text('$key:$value')).toList(),
                        Text('TCG: ${cardData.price['tcg']}'),
                        Text('TCG: ${cardData.price['tcg_foil']}'),
                      ],
                    ),
                    const SizedBox(height: 3,),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // cardData.price.forEach((key, value) {Text('$key:$value')})
                        // cardData.price.map((key, value) => Text('$key:$value')).toList(),
                        Text('CDM: ${cardData.price['cardmarket']}'),
                        Text(
                            'CDM: ${cardData.price['cardmarket_foil']}'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
