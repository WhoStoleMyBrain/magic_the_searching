import 'package:flutter/material.dart';
import 'card_image_display.dart';
import 'card_price_display.dart';
import '../screens/card_detail_screen.dart';
import '../scryfall_api_json_serialization/card_info.dart';

class CardDisplay extends StatelessWidget {
  final CardInfo cardInfo;

  const CardDisplay({super.key, required this.cardInfo});

  void cardTapped(BuildContext ctx, String id) {
    Navigator.of(ctx).pushNamed(CardDetailScreen.routeName, arguments: id);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return InkWell(
      onTap: () {
        cardTapped(context, cardInfo.id);
      },
      child: Card(
        shadowColor: Colors.transparent,
        color: Colors.transparent,
        child: Container(
          alignment: Alignment.topLeft,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.bottomRight,
              stops: [0.1, 0.9],
              colors: [
                Color.fromRGBO(199, 195, 205, 1.0),
                Color.fromRGBO(218, 229, 223, 1.0),
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AspectRatio(
                aspectRatio: 1 / 1.4,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: CardImageDisplay(
                      cardInfo: cardInfo, mediaQuery: mediaQuery),
                ),
              ),
              CardPriceDisplay(cardInfo: cardInfo),
            ],
          ),
        ),
      ),
    );
  }
}
