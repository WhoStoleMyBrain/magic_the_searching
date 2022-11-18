import 'package:flutter/material.dart';

import '../scryfall_api_json_serialization/card_info.dart';
import 'package:url_launcher/url_launcher.dart' as url;

class CardDetails extends StatelessWidget {
  const CardDetails({
    Key? key,
    required this.textStyle,
    required this.cardInfo,
  }) : super(key: key);

  final TextStyle textStyle;
  final CardInfo cardInfo;

  @override
  Widget build(BuildContext context) {
    // print(cardInfo.purchaseUris?.toJson());
    // print(cardInfo.toJson());
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Text(
                'Normal',
                style: textStyle,
              )),
              Expanded(
                  child: Text(
                'Foil',
                style: textStyle,
              )),
            ],
          ),
          const Divider(
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
          const SizedBox(
            height: 10,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Text('${cardInfo.purchaseUris?.tcgplayer}'),
              getLinkButton('Scryfall', cardInfo.scryfallUri),
              getLinkButton('Cardmarket', cardInfo.purchaseUris?.cardmarket),
              getLinkButton('TCGPlayer', cardInfo.purchaseUris?.tcgplayer),
            ],
          ),
        ],
      ),
    );
  }

  Expanded buildSinglePriceItem(String name, String? value, String currency) {
    return Expanded(
      child: Text(
        '$name:  $currency${value ?? '--.--'}',
        style: textStyle,
      ),
    );
  }

  TextButton getLinkButton(String name, String? url) {
    return TextButton(
      onPressed: (url == null)
          ? null
          : () {
              _launchURL(url);
            },
      child: Text(
        'Open on $name',
        style: textStyle,
      ),
    );
  }

  Future<void> _launchURL(String webpage) async {
    if (!await url.launch(webpage)) throw 'Could not launch $webpage';
  }
}
