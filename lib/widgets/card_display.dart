import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:magic_the_searching/helpers/scryfall_request_handler.dart';
import '../helpers/camera_helper.dart';
import '../screens/card_detail_screen.dart';
import '../scryfall_api_json_serialization/card_info.dart';
import '../scryfall_api_json_serialization/image_uris.dart';

class CardDisplay extends StatelessWidget {
  // final CardData cardData;
  final CardInfo cardInfo;

  const CardDisplay(
      // {Key? key, required this.cardData})
      {Key? key,
      required this.cardInfo})
      : super(key: key);

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
        height: mediaQuery.size.height,
        child: Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CardImageDisplay(cardInfo: cardInfo, mediaQuery: mediaQuery),
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
                buildSinglePriceItem('TCG', 'tcg', '\$'),
                buildSinglePriceItem('TCG', 'tcg_foil', '\$'),
                // Expanded(child: Container()),
              ],
            ),
            const SizedBox(
              height: 3,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildSinglePriceItem('CDM', 'cardmarket', '€'),
                buildSinglePriceItem('CDM', 'cardmarket_foil', '€'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Expanded buildSinglePriceItem(String name, String mapKey, String currency) {
    return Expanded(
      child: Text(
        '$name: $currency${cardInfo.prices?.usd}',
        style: TextStyle(
          fontSize: (double.parse(cardInfo.prices?.usd ?? '0')) >= 100
              ? (12 -
                  (double.parse(cardInfo.prices?.usd ?? '')).toString().length +
                  5)
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
  var _hasLocalImage = false;
  late File _storedImage;
  // bool pictureLoaded = false;

  Future<void> getLocalImage() async {
    //rewrite logic: if has cardFaces -> twosided, if not: onesided.
    late File localFile;
    if (!CardImageDisplay.pictureLoaded) {
      if (widget.cardInfo.hasTwoSides) {
        var fileExists = await CameraHelper.doesLocalFileExist(
            widget.cardInfo.cardFaces?[_side]?.normal ?? '');
        if (fileExists && _side == 1) {
          if (path.basename(
                  widget.cardInfo.cardFaces?[0]?.normal.toString() ?? '') ==
              path.basename(
                  widget.cardInfo.cardFaces?[1]?.normal.toString() ?? '')) {
            localFile = await CameraHelper.saveFileLocally(
                '${widget.cardInfo.cardFaces?[1]?.normal.toString()}back');
          } else {
            localFile = await CameraHelper.saveFileLocally(
                '${widget.cardInfo.cardFaces?[1]?.normal.toString()}');
          }
        } else {
          var fileExists = await CameraHelper.doesLocalFileExist(
              widget.cardInfo.imageUris?.normal ?? '');
          if (fileExists) {
            localFile = await CameraHelper.saveFileLocally(
                widget.cardInfo.imageUris?.normal ?? '');
          }
          // else {
          //   localFile = await CameraHelper.saveFileLocally(
          //       widget.cardInfo.imageUris?.normal ?? '');
          // }
        }
        _storedImage = localFile;
        _hasLocalImage = fileExists;
        CardImageDisplay.pictureLoaded = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getLocalImage(),
      builder: (context, snapshot) {
        return Stack(
          children: [
            (snapshot.connectionState == ConnectionState.done)
                ? displayImage()
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
                (widget.cardInfo.imageUris == null))
              Positioned(
                left: (widget.mediaQuery.size.width -
                            widget.mediaQuery.padding.horizontal) /
                        2 /
                        2 -
                    50,
                top: (widget.mediaQuery.size.height / 3) - 50 - 10,
                child: MaterialButton(
                  onPressed: () {
                    setState(() {
                      CardImageDisplay.pictureLoaded = false;
                      getLocalImage();
                      _side == 0 ? _side = 1 : _side = 0;
                    });
                  },
                  child: const Icon(
                    Icons.compare_arrows,
                    size: 35,
                    color: Colors.black87,
                  ),
                  height: 50,
                  shape: const CircleBorder(),
                  color: const Color.fromRGBO(128, 128, 128, 0.5),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget displayImage() {
    return _hasLocalImage
        ? ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(
              _storedImage,
              fit: BoxFit.cover,
              width: (widget.mediaQuery.size.width -
                      widget.mediaQuery.padding.horizontal) /
                  2,
              height: (widget.mediaQuery.size.height / 3),
            ),
          )
        : displayNonLocalImage();
  }

  Widget displayNonLocalImage() {
    List<ImageLinks?>? localImages =
        (widget.cardInfo.hasTwoSides && (widget.cardInfo.imageUris == null))
            ? widget.cardInfo.cardFaces
            : [widget.cardInfo.imageUris];
    return localImages?[_side]?.normal?.contains('http') ?? false
        ? ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              localImages?[_side]?.normal ?? '',
              fit: BoxFit.cover,
              width: (widget.mediaQuery.size.width -
                      widget.mediaQuery.padding.horizontal) /
                  2,
              height: (widget.mediaQuery.size.height / 3),
            ),
          )
        : localImages?[_side]?.normal == ''
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: const Image(
                  image: AssetImage(ScryfallRequestHandler.isshinLocal),
                ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image(
                  image: AssetImage(
                    localImages?[_side]?.normal ?? '',
                  ),
                ),
              );
  }
}
