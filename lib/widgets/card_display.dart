import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:magic_the_searching/helpers/scryfall_request_handler.dart';
import '../helpers/camera_helper.dart';
import '../models/card_data.dart';

class CardDisplay extends StatelessWidget {
  final CardData cardData;
  final Function cardTapped;

  const CardDisplay(
      {Key? key, required this.cardData, required this.cardTapped})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return InkWell(
      onTap: () {
        cardTapped(context, cardData.id);
      },
      child: SizedBox(
        height: mediaQuery.size.height,
        child: Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CardImageDisplay(cardData: cardData, mediaQuery: mediaQuery),
              CardPriceDisplay(cardData: cardData),
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
    required this.cardData,
  }) : super(key: key);

  final CardData cardData;

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
        '$name: $currency${cardData.price[mapKey]}',
        style: TextStyle(
          fontSize: (double.tryParse(cardData.price[mapKey]) ?? 0) >= 100
              ? (12 -
                  (double.tryParse(cardData.price[mapKey]) ?? 0)
                      .toString()
                      .length +
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
    required this.cardData,
    required this.mediaQuery,
  }) : super(key: key);

  final CardData cardData;
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
    late File localFile;
    if (!CardImageDisplay.pictureLoaded) {
      var fileExists =
          await CameraHelper.doesLocalFileExist(widget.cardData.images[_side]);
      if (fileExists && widget.cardData.hasTwoSides && (_side == 1)) {
        if (path.basename(widget.cardData.images[0]) ==
            path.basename(widget.cardData.images[1])) {
          localFile = await CameraHelper.saveFileLocally(
              '${widget.cardData.images[_side]}back');
        } else {
          localFile =
              await CameraHelper.saveFileLocally(widget.cardData.images[_side]);
        }
      } else {
        localFile =
            await CameraHelper.saveFileLocally(widget.cardData.images[_side]);
      }
      _storedImage = localFile;
      _hasLocalImage = fileExists;
      CardImageDisplay.pictureLoaded = true;
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
            if (widget.cardData.hasTwoSides)
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
        : widget.cardData.images[_side].contains('http')
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  widget.cardData.images[_side],
                  fit: BoxFit.cover,
                  width: (widget.mediaQuery.size.width -
                          widget.mediaQuery.padding.horizontal) /
                      2,
                  height: (widget.mediaQuery.size.height / 3),
                ),
              )
            : widget.cardData.images[_side] == ''
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
                        widget.cardData.images[_side],
                      ),
                    ),
                  );
  }
}
