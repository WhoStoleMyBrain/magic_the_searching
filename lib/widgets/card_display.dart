import 'dart:io';

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
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CardImageDisplay(cardData: cardData, mediaQuery: mediaQuery),
                Padding(
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
                          Expanded(
                              child: Text('TCG:  \$${cardData.price['tcg']}')),
                          // Expanded(child: Container()),
                          Expanded(
                              child: Text(
                                  'TCG:  \$${cardData.price['tcg_foil']}')),
                        ],
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              child: Text(
                                  'CDM: €${cardData.price['cardmarket']}')),
                          Expanded(
                              child: Text(
                                  'CDM: €${cardData.price['cardmarket_foil']}')),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CardImageDisplay extends StatefulWidget {
  CardImageDisplay({
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
    if (!CardImageDisplay.pictureLoaded) {
      var fileExists =
          await CameraHelper.doesLocalFileExist(widget.cardData.images[_side]);
      var localFile =
          await CameraHelper.saveFileLocally(widget.cardData.images[_side]);
      _storedImage = localFile;
      _hasLocalImage = fileExists;
      // _hasLocalImage = false;
      CardImageDisplay.pictureLoaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    // nothing();
    return FutureBuilder(
      future: getLocalImage(),
      builder: (context, snapshot) {
        // print(snapshot);
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

  Image displayImage() {
    return _hasLocalImage
        ? Image.file(
            _storedImage,
            fit: BoxFit.cover,
            width: (widget.mediaQuery.size.width -
                    widget.mediaQuery.padding.horizontal) /
                2,
            height: (widget.mediaQuery.size.height / 3),
          )
        : widget.cardData.images[_side].contains('http')
            ? Image.network(
                widget.cardData.images[_side],
                fit: BoxFit.cover,
                width: (widget.mediaQuery.size.width -
                        widget.mediaQuery.padding.horizontal) /
                    2,
                height: (widget.mediaQuery.size.height / 3),
              )
            : widget.cardData.images[_side] == ''
                ? const Image(
                    image: AssetImage(ScryfallRequestHandler.isshinLocal),
                  )
                : Image(image: AssetImage(widget.cardData.images[_side]));
  }
}
