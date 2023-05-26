import 'package:flutter/material.dart';
import 'card_image_display.dart';
import 'card_price_display.dart';
import '../screens/card_detail_screen.dart';
import '../scryfall_api_json_serialization/card_info.dart';

class CardDisplay extends StatelessWidget {
  final CardInfo cardInfo;

  const CardDisplay({Key? key, required this.cardInfo}) : super(key: key);

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
    );
  }
}
