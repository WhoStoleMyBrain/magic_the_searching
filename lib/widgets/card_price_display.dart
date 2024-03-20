import 'package:flutter/material.dart';

import '../scryfall_api_json_serialization/card_info.dart';

class CardPriceDisplay extends StatelessWidget {
  const CardPriceDisplay({
    super.key,
    required this.cardInfo,
  });

  final CardInfo cardInfo;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 0,
      child: Container(
        // height: 90,
        // color: Colors.transparent,
        // color: Colors.white,
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            buildCombinedPriceItem('TCG Player', cardInfo.prices?.usd,
                cardInfo.prices?.usdFoil, '\$'),
            const SizedBox(
              height: 3,
            ),
            buildCombinedPriceItem('Cardmarket', cardInfo.prices?.eur,
                cardInfo.prices?.eurFoil, '€')
          ],
        ),
      ),
    );
  }

  Text buildCombinedPriceItem(
      String name, String? value, String? foilValue, String currency) {
    return Text(
      '$name: $currency${value ?? "--.--"} ($currency${foilValue ?? "--.--"})',
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: (double.parse(value ?? '0')) >= 1000
            ? (12 - (double.parse(value ?? '')).toString().length + 6)
            : 12,
      ),
    );
  }
}
