import 'package:flutter/material.dart';

import '../scryfall_api_json_serialization/card_info.dart';
import 'package:url_launcher/url_launcher.dart' as url;

class CardDetails extends StatelessWidget {
  const CardDetails({
    super.key,
    required this.textStyle,
    required this.cardInfo,
  });

  final TextStyle textStyle;
  final CardInfo cardInfo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                'Normal',
                style: textStyle,
              ),
              Text(
                'Foil',
                style: textStyle,
              ),
            ],
          ),
          const Divider(
            color: Colors.black,
            thickness: 1,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildSinglePriceItem('TCG', cardInfo.prices?.usd, '\$'),
              buildSinglePriceItem('TCG', cardInfo.prices?.usdFoil, '\$'),
            ],
          ),
          const SizedBox(
            height: 4,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
              getLinkButton('Scryfall', cardInfo.scryfallUri),
              getLinkButton('Cardmarket', cardInfo.purchaseUris?.cardmarket),
              getLinkButton('TCGPlayer', cardInfo.purchaseUris?.tcgplayer),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildSinglePriceItem(String name, String? value, String currency) {
    return Text(
      '$name:\t$currency${value ?? '--.--'}',
      style: textStyle,
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
    if (!await url.launchUrl(Uri.parse(webpage))) {
      throw 'Could not launch $webpage';
    }
  }
}
