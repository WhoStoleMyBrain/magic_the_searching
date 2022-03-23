import 'dart:io';

import 'package:flutter/material.dart';
import 'package:magic_the_searching/helpers/db_helper.dart';
import 'package:magic_the_searching/helpers/scryfall_query_maps.dart';
import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher.dart' as url;
import 'package:magic_the_searching/helpers/camera_helper.dart';
import 'package:provider/provider.dart';
import 'package:magic_the_searching/providers/card_data_provider.dart';

import '../helpers/scryfall_request_handler.dart';
import '../scryfall_api_json_serialization/card_info.dart';
import '../scryfall_api_json_serialization/image_uris.dart';

// import '../models/card_data.dart';

class CardDetailScreen extends StatelessWidget {
  static const routeName = '/card-detail';

  const CardDetailScreen({Key? key}) : super(key: key);
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
              child: const Text('Okay'),
            )
          ],
        );
      },
    );
  }

  Future<void> _startSearchForCards(BuildContext ctx, String text,
      Function dbHelperFunction, Map<String, String> queryParameters) async {
    final cardDataProvider = Provider.of<CardDataProvider>(ctx, listen: false);
    cardDataProvider.query = text;
    cardDataProvider.isStandardQuery = false;
    cardDataProvider.dbHelperFunction = dbHelperFunction;
    cardDataProvider.queryParameters = queryParameters;
    bool requestSuccessful = await cardDataProvider.processQuery();
    if (!requestSuccessful) {
      _showFailedQuery(ctx, text);
      return;
    }
    Navigator.of(ctx).pop();
  }

  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context)?.settings.arguments as String;
    final CardInfo cardInfo =
        Provider.of<CardDataProvider>(context, listen: false).getCardById(id);
    final mediaQuery = MediaQuery.of(context);
    const TextStyle textStyle = TextStyle(
      fontSize: 20,
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        actions: [
          getRefinedSearchButton(
            context,
            cardInfo,
            DBHelper.getHistoryData,
            ScryfallQueryMaps.languagesMap,
            'All Languages',
          ),
          getRefinedSearchButton(
              context,
              cardInfo,
              DBHelper.getVersionsOrPrintsData,
              ScryfallQueryMaps.printsMap,
              'All Prints'),
          getRefinedSearchButton(
              context,
              cardInfo,
              DBHelper.getVersionsOrPrintsData,
              ScryfallQueryMaps.versionMap,
              'All Arts'),
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
                CardImageDisplay(cardInfo: cardInfo, mediaQuery: mediaQuery),
                CardDetails(textStyle: textStyle, cardInfo: cardInfo),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextButton getRefinedSearchButton(
      BuildContext context,
      CardInfo cardInfo,
      Function dbHelperFunction,
      Map<String, String> queryMap,
      String displayText) {
    return TextButton(
      onPressed: () {
        _startSearchForCards(
          context,
          cardInfo.name ?? '',
          dbHelperFunction,
          queryMap,
        );
      },
      child: Text(
        displayText,
        style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary, fontSize: 20),
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

  @override
  State<CardImageDisplay> createState() => _CardImageDisplayState();
}

class _CardImageDisplayState extends State<CardImageDisplay> {
  int _side = 0;
  var _hasLocalImage = false;
  late File _storedImage;

  // Future<void> getLocalImage2() async {
  //   late File localFile;
  //   var fileExists =
  //       await CameraHelper.doesLocalFileExist(widget.cardData.images[_side]);
  //   if (fileExists && widget.cardData.hasTwoSides && (_side == 1)) {
  //     if (path.basename(widget.cardData.images[0]) ==
  //         path.basename(widget.cardData.images[1])) {
  //       localFile = await CameraHelper.saveFileLocally(
  //           '${widget.cardData.images[_side]}back');
  //     }
  //   } else {
  //     localFile =
  //         await CameraHelper.saveFileLocally(widget.cardData.images[_side]);
  //   }
  //   _storedImage = localFile;
  //   _hasLocalImage = fileExists;
  // }

  Future<void> getLocalImage() async {
    //rewrite logic: if has cardFaces -> twosided, if not: onesided.
    late File localFile;
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getLocalImage(),
      builder: (context, snapshot) {
        return Stack(
          children: [
            (snapshot.connectionState != ConnectionState.none)
                ? displayImage()
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
            if (widget.cardInfo.hasTwoSides  && (widget.cardInfo.imageUris == null)) getFlipButton(),
          ],
        );
      },
    );
  }

  Widget displayImage() {
    return _hasLocalImage
        ? ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.file(
              _storedImage,
              fit: BoxFit.cover,
            ),
          )
        : displayNonLocalImage();
  }

  Widget displayNonLocalImage() {
    List<ImageLinks?>? localImages = (widget.cardInfo.hasTwoSides && (widget.cardInfo.imageUris == null))
        ? widget.cardInfo.cardFaces
        : [widget.cardInfo.imageUris];
    return localImages?[_side]?.normal?.contains('http') ?? false
        ? ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              localImages?[_side]?.normal ?? '',
              fit: BoxFit.cover,
            ),
          )
        : localImages?[_side]?.normal == ''
            ? ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: const Image(
                  image: AssetImage(ScryfallRequestHandler.isshinLocal),
                ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image(
                  image: AssetImage(
                    localImages?[_side]?.normal ?? '',
                  ),
                ),
              );
  }

  Positioned getFlipButton() {
    return Positioned(
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
    );
  }
}

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
              buildSinglePriceItem('TCG', 'tcg', '\$'),
              buildSinglePriceItem('TCG', 'tcg_foil', '\$'),
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
          const SizedBox(
            height: 10,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              getLinkButton('Scryfall', 'scryfall'),
              getLinkButton('Cardmarket', 'cardmarket'),
              getLinkButton('TCGPlayer', 'tcg'),
            ],
          ),
        ],
      ),
    );
  }

  Expanded buildSinglePriceItem(String name, String mapKey, String currency) {
    return Expanded(
      child: Text(
        '$name:  $currency${cardInfo.prices?.usd}',
        style: textStyle,
      ),
    );
  }

  TextButton getLinkButton(String name, String mapKey) {
    return TextButton(
      onPressed: () {
        // _launchURL(cardInfo.purchaseUris?.cardmarket ?? '');
        _launchURL(cardInfo.scryfallUri ?? '');
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
