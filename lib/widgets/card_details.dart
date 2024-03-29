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
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              buildCombinedPriceItem('TCG Player', cardInfo.prices?.usd,
                  cardInfo.prices?.usdFoil, '\$', textStyle),
              const SizedBox(
                height: 3,
              ),
              buildCombinedPriceItem('Cardmarket', cardInfo.prices?.eur,
                  cardInfo.prices?.eurFoil, '€', textStyle)
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

  Text buildCombinedPriceItem(String name, String? value, String? foilValue,
      String currency, TextStyle style) {
    return Text(
      '$name: $currency${value ?? "--.--"} ($currency${foilValue ?? "--.--"})',
      overflow: TextOverflow.ellipsis,
      style: style,
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
