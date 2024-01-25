import 'package:flutter/material.dart';

import '../scryfall_api_json_serialization/card_info.dart';

class CardPriceDisplay extends StatelessWidget {
  const CardPriceDisplay({
    Key? key,
    required this.cardInfo,
  }) : super(key: key);

  final CardInfo cardInfo;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0,
      child: Container(
        height: 90,
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text('Normal')),
                Expanded(child: Text('Foil')),
              ],
            ),
            const Divider(
              height: 5,
              color: Colors.black,
              thickness: 1,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                buildSinglePriceItem('TCG', cardInfo.prices?.usd, '\$'),
                buildSinglePriceItem('TCG', cardInfo.prices?.usdFoil, '\$'),
              ],
            ),
            const SizedBox(
              height: 3,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildSinglePriceItem('CDM', cardInfo.prices?.eur, '€'),
                buildSinglePriceItem('CDM', cardInfo.prices?.eurFoil, '€'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Expanded buildSinglePriceItem(String name, String? value, String currency) {
    return Expanded(
      child: Text(
        '$name: $currency${value ?? '--.--'}',
        style: TextStyle(
          fontSize: (double.parse(value ?? '0')) >= 100
              ? (12 - (double.parse(value ?? '')).toString().length + 5)
              : 12,
        ),
      ),
    );
  }
}
