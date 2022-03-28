import 'dart:io';

import 'package:flutter/material.dart';
import 'package:magic_the_searching/helpers/scryfall_query_maps.dart';

import 'package:url_launcher/url_launcher.dart' as url;

import 'package:provider/provider.dart';
import 'package:magic_the_searching/providers/card_data_provider.dart';

import '../providers/settings.dart';
import '../scryfall_api_json_serialization/card_info.dart';
import '../scryfall_api_json_serialization/image_uris.dart';

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
      Map<String, String> queryParameters) async {
    final cardDataProvider = Provider.of<CardDataProvider>(ctx, listen: false);
    cardDataProvider.query = text;
    cardDataProvider.isStandardQuery = false;
    // cardDataProvider.dbHelperFunction = dbHelperFunction;
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
    final id = ModalRoute.of(context)?.settings.arguments as String? ?? '';
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
            ScryfallQueryMaps.inEnglishMap,
            'In English',
          ),
          getRefinedSearchButton(
              context, cardInfo, ScryfallQueryMaps.printsMap, 'All Prints'),
          getRefinedSearchButton(
              context, cardInfo, ScryfallQueryMaps.versionMap, 'All Arts'),
        ],
      ),
      // drawer: const AppDrawer(),
      body: SizedBox(
        height: mediaQuery.size.height,
        child: Card(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                    height:
                        (mediaQuery.size.height - mediaQuery.padding.top - 30) -
                            100 -
                            32 -
                            16,
                    child: SingleChildScrollView(
                        child: CardImageDisplay(
                            cardInfo: cardInfo, mediaQuery: mediaQuery))),
                CardDetails(textStyle: textStyle, cardInfo: cardInfo),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextButton getRefinedSearchButton(BuildContext context, CardInfo cardInfo,
      Map<String, String> queryMap, String displayText) {
    return TextButton(
      onPressed: () {
        _startSearchForCards(
          context,
          cardInfo.name ?? '',
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
  late Image? _networkImage;
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
    return Card(
        child: Container(
      height:
          (widget.mediaQuery.size.height - widget.mediaQuery.padding.top - 30) -
              100 -
              32 -
              16 -
              32,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.cardInfo.name ?? 'No name found for this card.',
            style: const TextStyle(
              fontSize: 24,
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Text(
            widget.cardInfo.oracleText ?? 'No Oracle text found',
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    ));
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
                    borderRadius: BorderRadius.circular(15),
                    child: (_hasInternetConnection && settings.useImagesFromNet)
                        ? _networkImage
                        : cardText(),
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
            if (widget.cardInfo.hasTwoSides &&
                (widget.cardInfo.imageUris?.normal == null) &&
                settings.useImagesFromNet)
              getFlipButton(settings),
          ],
        );
      },
    );
  }

  Positioned getFlipButton(Settings settings) {
    return Positioned(
      left: (widget.mediaQuery.size.width -
                  widget.mediaQuery.padding.horizontal) /
              2 -
          50,
      top: (widget.mediaQuery.size.height * 2 / 3) - 70 - 10,
      child: MaterialButton(
        onPressed: () {
          setState(() {
            getLocalImage(settings);
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
