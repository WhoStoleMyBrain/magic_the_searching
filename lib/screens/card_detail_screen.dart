import 'package:flutter/material.dart';
import 'package:magic_the_searching/helpers/db_helper.dart';
import 'package:magic_the_searching/helpers/scryfall_query_maps.dart';

import 'package:url_launcher/url_launcher.dart' as url;

import 'package:provider/provider.dart';
import 'package:magic_the_searching/providers/card_data_provider.dart';

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
  late Image _networkImage;

  Future<void> getLocalImage() async {
    // CardImageDisplay.pictureLoaded = true;
    // print(widget.cardInfo.toJson()['hasTwoSides']);
    // print(widget.cardInfo.hasTwoSides);
    List<ImageLinks?>? localImages =
        (widget.cardInfo.hasTwoSides && (widget.cardInfo.imageUris?.normal == null))
            ? widget.cardInfo.cardFaces
            : [widget.cardInfo.imageUris];
    _networkImage = Image.network(
      localImages?[_side]?.normal ?? (localImages?[_side]?.small ?? ''),
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getLocalImage(),
      builder: (context, snapshot) {
        return Stack(
          children: [
            (snapshot.connectionState == ConnectionState.done)
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: _networkImage,
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
            if (widget.cardInfo.hasTwoSides &&
                (widget.cardInfo.imageUris?.normal == null))
              getFlipButton(),
          ],
        );
      },
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
    // print(cardInfo.purchaseUris?.toJson());
    print(cardInfo.toJson());
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
      onPressed: (url == null) ? null : () {
        // _launchURL(cardInfo.purchaseUris?.cardmarket ?? '');
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
