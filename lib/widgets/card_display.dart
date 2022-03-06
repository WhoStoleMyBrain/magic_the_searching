import 'package:flutter/material.dart';
import '../models/card_data.dart';

class CardDisplay extends StatelessWidget {
  final CardData cardData;
  final Function cardTapped;

  const CardDisplay(
      {Key? key, required this.cardData, required this.cardTapped})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return InkWell(
      onTap: () {cardTapped(context, cardData.id);},
      child: SizedBox(
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
