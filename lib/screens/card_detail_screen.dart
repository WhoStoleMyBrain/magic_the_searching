import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:magic_the_searching/helpers/camera_helper.dart';
import 'package:provider/provider.dart';
import 'package:magic_the_searching/providers/card_data_provider.dart';

import '../models/card_data.dart';

class CardDetailScreen extends StatelessWidget {
  static const routeName = '/card-detail';

  const CardDetailScreen({Key? key}) : super(key: key);

  // final CardData cardData;
  Future<void> _showFailedQuery(BuildContext ctx, String query) async {
    return showDialog<void>(
      context: ctx,
      builder: (bCtx) {
        return AlertDialog(
          title: const Text('No results found'),
          content: SingleChildScrollView(
              child: Text('No results matching \'$query\' found.')),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(bCtx).pop();
                },
                child: const Text('Okay'))
          ],
        );
      },
    );
  }

  Future<void> _startSearchForVersions(BuildContext ctx, String text) async {
    final cardDataProvider = Provider.of<CardDataProvider>(ctx, listen: false);
    cardDataProvider.query = text[0] == '!' ? text : '!' + text;
    bool requestSuccessful = await cardDataProvider.processVersionsQuery();
    if (!requestSuccessful) {
      _showFailedQuery(ctx, text);
      return;
    }
    // Navigator.of(ctx).pushReplacementNamed('/');
    Navigator.of(ctx).pop();
    // Navigator.of(ctx).pushNamedAndRemoveUntil('/', ModalRoute.withName('/'));
  }

  Future<void> _startSearchForPrints(BuildContext ctx, String text) async {
    final cardDataProvider = Provider.of<CardDataProvider>(ctx, listen: false);
    cardDataProvider.query = text[0] == '!' ? text : '!' + text;
    bool requestSuccessful = await cardDataProvider.processPrintsQuery();
    if (!requestSuccessful) {
      _showFailedQuery(ctx, text);
      return;
    }
    // Navigator.of(ctx).pushReplacementNamed('/');
    Navigator.of(ctx).pop();
    // Navigator.of(ctx).pushNamedAndRemoveUntil('/', ModalRoute.withName('/'));
  }

  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context)?.settings.arguments as String;
    final cardData =
        Provider.of<CardDataProvider>(context, listen: false).getCardById(id);
    final mediaQuery = MediaQuery.of(context);
    // const double fontSize = 20;
    const TextStyle textStyle = TextStyle(
      fontSize: 24,
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              _startSearchForPrints(context, cardData.name);
            },
            child: Text('All Prints',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 20)),
          ),
          TextButton(
            onPressed: () {
              _startSearchForVersions(context, cardData.name);
            },
            child: Text('All Arts',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 20)),
          ),
        ],
      ),
      body: SizedBox(
        height: mediaQuery.size.height,
        child: Card(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CardImageDisplay(cardData: cardData, mediaQuery: mediaQuery),
                CardDetails(textStyle: textStyle, cardData: cardData),
              ],
            ),
          ),
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

  @override
  State<CardImageDisplay> createState() => _CardImageDisplayState();
}

class _CardImageDisplayState extends State<CardImageDisplay> {
  int _side = 0;
  var _hasLocalImage = false;
  late File _storedImage;
  // bool _isLoading = false;

  Future<void> getLocalImage() async {
    late File localFile;
    var fileExists =
        await CameraHelper.doesLocalFileExist(widget.cardData.images[_side]);
    if (fileExists && widget.cardData.hasTwoSides && (_side == 1)) {
      if (path.basename(widget.cardData.images[0]) ==
          path.basename(widget.cardData.images[1])) {
        localFile = await CameraHelper.saveFileLocally(
            '${widget.cardData.images[_side]}back');
      }
    } else {
      localFile =
      await CameraHelper.saveFileLocally(widget.cardData.images[_side]);
    }
    // print(_side);
    // print(fileExists);
    // print(localFile.toString());
    _storedImage = localFile;
    _hasLocalImage = fileExists;
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getLocalImage(),
      builder: (context, snapshot) {
        // print('detail');
        // print(_hasLocalImage);
        // print(_storedImage.path);

        return Stack(
          // alignment: Alignment.center ,
          children: [
            // _isLoading ? const Center(child: CircularProgressIndicator(),) :
            (snapshot.connectionState != ConnectionState.none)
                ? _hasLocalImage
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.file(
                          _storedImage,
                          fit: BoxFit.cover,
                          // fit: BoxFit.cover,
                          width: (widget.mediaQuery.size.width -
                              widget.mediaQuery.padding.horizontal),
                          height: (widget.mediaQuery.size.height * 2 / 3),
                        ),
                      )
                    : widget.cardData.images[_side].contains('http')
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.network(
                              widget.cardData.images[_side],
                              fit: BoxFit.cover,
                              width: (widget.mediaQuery.size.width -
                                  widget.mediaQuery.padding.horizontal),
                              height: (widget.mediaQuery.size.height * 2 / 3),
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image(
                                image:
                                    AssetImage(widget.cardData.images[_side])),
                          )
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
            if (widget.cardData.hasTwoSides)
              Positioned(
                left: (widget.mediaQuery.size.width -
                            widget.mediaQuery.padding.horizontal) /
                        2 -
                    50,
                top: (widget.mediaQuery.size.height * 2 / 3) - 70 - 10,
                child: MaterialButton(
                  onPressed: () {
                    setState(() {
                      getLocalImage();
                      _side == 0 ? _side = 1 : _side = 0;
                    });
                  },
                  child: const Icon(
                    Icons.compare_arrows,
                    size: 50,
                    color: Colors.black87,
                  ),
                  height: 70,
                  shape: const CircleBorder(),
                  color: const Color.fromRGBO(128, 128, 128, 0.5),
                ),
              ),
            // if (_hasLocalImage)
            //   Positioned(
            //     left: (widget.mediaQuery.size.width -
            //                 widget.mediaQuery.padding.horizontal) /
            //             2 -
            //         50,
            //     top: (widget.mediaQuery.size.height * 2 / 3) - 70 - 10,
            //     child: MaterialButton(
            //       onPressed: () {
            //         // setState(() {
            //         //   _side == 0 ? _side = 1 : _side = 0;
            //         // });
            //       },
            //       child: const Icon(
            //         Icons.car_rental,
            //         size: 50,
            //         color: Colors.black87,
            //       ),
            //       height: 70,
            //       shape: const CircleBorder(),
            //       color: const Color.fromRGBO(128, 128, 128, 0.5),
            //     ),
            //   ),
          ],
        );
      },
    );
  }
}

class CardDetails extends StatelessWidget {
  const CardDetails({
    Key? key,
    required this.textStyle,
    required this.cardData,
  }) : super(key: key);

  final TextStyle textStyle;
  final CardData cardData;

  @override
  Widget build(BuildContext context) {
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
              Expanded(
                  child: Text(
                'TCG:  \$${cardData.price['tcg']}',
                style: textStyle,
              )),
              // Expanded(child: Container()),
              Expanded(
                  child: Text(
                'TCG:  \$${cardData.price['tcg_foil']}',
                style: textStyle,
              )),
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
                'CDM: €${cardData.price['cardmarket']}',
                style: textStyle,
              )),
              Expanded(
                  child: Text(
                'CDM: €${cardData.price['cardmarket_foil']}',
                style: textStyle,
              )),
            ],
          ),
        ],
      ),
    );
  }
}
