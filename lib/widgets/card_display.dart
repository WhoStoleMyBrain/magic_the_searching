import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings.dart';
import '../screens/card_detail_screen.dart';
import '../scryfall_api_json_serialization/card_info.dart';
import '../scryfall_api_json_serialization/image_uris.dart';

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
      child: SizedBox(
        // height: mediaQuery.size.height,
        child: Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                // width: mediaQuery.size.width,
                height: (mediaQuery.size.height - mediaQuery.padding.top - 30) /
                        2 -
                    100 -
                    16 -
                    16, // Size of whole card - size of text display - padding and insets.
                child: SingleChildScrollView(
                    child: CardImageDisplay(
                        cardInfo: cardInfo, mediaQuery: mediaQuery)),
              ),
              CardPriceDisplay(cardInfo: cardInfo),
            ],
          ),
        ),
      ),
    );
  }
}

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
        height: 100,
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Expanded(child: Text('Normal')),
                Expanded(child: Text('Foil')),
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
                // Expanded(child: Container()),
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

class CardImageDisplay extends StatefulWidget {
  const CardImageDisplay({
    Key? key,
    required this.cardInfo,
    required this.mediaQuery,
  }) : super(key: key);

  final CardInfo cardInfo;
  final MediaQueryData mediaQuery;
  static bool pictureLoaded = false;

  @override
  State<CardImageDisplay> createState() => _CardImageDisplayState();
}

class _CardImageDisplayState extends State<CardImageDisplay> {
  // final _TotalTextSize = 0;
  int _side = 0;
  late Image _networkImage;
  late bool _hasInternetConnection;

  Future<void> getLocalImage(Settings settings) async {
    if (settings.useImagesFromNet) {
      try {
        final result = await InternetAddress.lookup('c1.scryfall.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          List<ImageUris?>? localImages = (widget.cardInfo.hasTwoSides &&
                  (widget.cardInfo.imageUris?.normal == null))
              ? widget.cardInfo.cardFaces
              : [widget.cardInfo.imageUris];
          _networkImage = Image.network(
            localImages?[_side]?.normal ?? (localImages?[_side]?.small ?? ''),
            height: (widget.mediaQuery.size.height -
                        widget.mediaQuery.padding.top -
                        30) /
                    2 -
                100 -
                16 -
                16,
            fit: BoxFit.cover,
          );
          _hasInternetConnection = true;
        }
      } on SocketException catch (_) {
        _hasInternetConnection = false;
      }
    } else {
      _hasInternetConnection = false;
    }
  }

  Widget cardText() {
    final mediaQuery = MediaQuery.of(context);
    return Card(
      child: Container(
        height: (mediaQuery.size.height - mediaQuery.padding.top - 30) /
          2 -
          100 -
          16 -
          32 + 8,
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Center(
                  child: Text(
                widget.cardInfo.name ?? 'No name found for this card.',
                style: const TextStyle(
                  fontSize: 16,
                ),
              )),
              const SizedBox(
                height: 10,
              ),
              Text(
                widget.cardInfo.oracleText ?? 'No Oracle text found',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<Settings>(context, listen: true);
    return FutureBuilder(
      future: getLocalImage(settings),
      builder: (context, snapshot) {
        return Stack(
          children: [
            (snapshot.connectionState == ConnectionState.done)
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: (_hasInternetConnection && settings.useImagesFromNet)
                        ? _networkImage
                        : cardText(),
                  )
                : SizedBox(
                    width: (widget.mediaQuery.size.width -
                            widget.mediaQuery.padding.horizontal) /
                        2,
                    height: (widget.mediaQuery.size.height / 3),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
            if (widget.cardInfo.hasTwoSides &&
                (widget.cardInfo.imageUris?.normal == null) &&
                settings.useImagesFromNet)
              Positioned(
                left: (widget.mediaQuery.size.width -
                            widget.mediaQuery.padding.horizontal) /
                        2 /
                        2 -
                    50,
                top: (widget.mediaQuery.size.height / 3) - 50 - 10 - 15,
                child: MaterialButton(
                  onPressed: () {
                    setState(() {
                      CardImageDisplay.pictureLoaded = false;
                      getLocalImage(settings);
                      _side == 0 ? _side = 1 : _side = 0;
                    });
                  },
                  child: const Icon(
                    Icons.compare_arrows,
                    size: 30,
                    color: Colors.black87,
                  ),
                  height: 45,
                  shape: const CircleBorder(),
                  color: const Color.fromRGBO(128, 128, 128, 0.5),
                ),
              ),
          ],
        );
      },
    );
  }
}
