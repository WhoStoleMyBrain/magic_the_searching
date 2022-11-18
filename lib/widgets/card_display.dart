import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
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
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SingleChildScrollView(
              child:
                  CardImageDisplay(cardInfo: cardInfo, mediaQuery: mediaQuery),
            ),
            CardPriceDisplay(cardInfo: cardInfo),
          ],
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
        height: 90,
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
              height: 5,
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
  int _side = 0;
  late Image? _networkImageStream;
  late bool _hasInternetConnection = true;
  late Stream<FileResponse> fileStream;

  Stream<FileResponse>? getLocalImage(Settings settings) {
    if (settings.useImagesFromNet) {
      List<ImageUris?>? localImages = (widget.cardInfo.hasTwoSides &&
              (widget.cardInfo.imageUris?.normal == null))
          ? widget.cardInfo.cardFaces
          : [widget.cardInfo.imageUris];
      fileStream = DefaultCacheManager().getImageFile(
          localImages?[_side]?.normal ?? (localImages?[_side]?.small ?? ''));
      _hasInternetConnection = true;
      return fileStream;
    }
    return null;
  }

  Widget cardText() {
    return Container(
      height: (widget.mediaQuery.size.height -
                  2 * widget.mediaQuery.padding.vertical -
                  2 * widget.mediaQuery.viewInsets.top) /
              2 -
          10 -
          90 -
          8 -
          10,
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Center(
            child: Text(
              widget.cardInfo.name ?? 'No name found for this card.',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
          Text(
            widget.cardInfo.manaCost ?? '',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(widget.cardInfo.typeLine ?? '',
              style: const TextStyle(fontSize: 12)),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                widget.cardInfo.oracleText ?? 'No Oracle text found',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                  '${widget.cardInfo.power ?? "-"}/${widget.cardInfo.toughness ?? "-"}'),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            'Set: ${widget.cardInfo.setName ?? 'Unknown Set'}',
            style: const TextStyle(
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<Settings>(context, listen: true);
    return StreamBuilder<FileResponse>(
      stream: getLocalImage(settings),
      builder: (context, snapshot) {
        if (!(snapshot.hasError) &&
            (snapshot.hasData || snapshot.data is DownloadProgress) &&
            settings.useImagesFromNet) {
          FileInfo fileInfo = snapshot.data as FileInfo;
          _networkImageStream = Image.file(
            File(
              fileInfo.file.path,
            ),
            fit: BoxFit.cover,
          );
        }
        if (snapshot.hasError) {
          _networkImageStream = null;
          _hasInternetConnection = false;
        }
        return Stack(
          // alignment: AlignmentDirectional.centerEnd,
          children: [
            (snapshot.connectionState == ConnectionState.done ||
                    !settings.useImagesFromNet)
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: (_hasInternetConnection && settings.useImagesFromNet)
                        ? _networkImageStream
                        : cardText(),
                  )
                : SizedBox(
                    width: (widget.mediaQuery.size.width -
                            widget.mediaQuery.padding.horizontal) /
                        2,
                    height: (widget.mediaQuery.size.height / 4),
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
