import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

import '../helpers/constants.dart';
import '../helpers/scryfall_query_maps.dart';
import '../helpers/navigation_helper.dart';
import '../providers/card_data_provider.dart';
import '../providers/color_provider.dart';
import '../providers/settings.dart';
import '../scryfall_api_json_serialization/card_info.dart';
import '../widgets/card_detail_image_display.dart';
import '../widgets/card_details.dart';

class CardDetailScreen extends StatefulWidget {
  static const routeName = '/card-detail';

  const CardDetailScreen({super.key});

  @override
  State<CardDetailScreen> createState() => _CardDetailScreenState();
}

class _CardDetailScreenState extends State<CardDetailScreen> {
  final GlobalKey _one = GlobalKey();

  final GlobalKey _two = GlobalKey();

  final GlobalKey _three = GlobalKey();

  final GlobalKey _four = GlobalKey();

  final GlobalKey _five = GlobalKey();

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((SharedPreferences prefs) {
      bool tutorialCardDetailSeen =
          prefs.getBool(Constants.tutorialCardDetailSeen) ?? false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!tutorialCardDetailSeen) {
          ShowCaseWidget.of(context)
              .startShowCase([_one, _two, _three, _four, _five]);
        }
      });
    });
  }

  Future<void> _showFailedQuery(BuildContext ctx, String query) async {
    return showDialog<void>(
      context: ctx,
      builder: (bCtx) {
        return AlertDialog(
          title: const Text('No results found'),
          titlePadding: const EdgeInsets.all(24.0),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(32))),
          backgroundColor: Colors.blueGrey.shade200,
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
    cardDataProvider.scryfallQueryMaps = queryParameters;

    if (kDebugMode) {
      print('starting search for cards in detail screen! $queryParameters');
    }
    await cardDataProvider.processQuery().then((bool value) {
      if (!value) {
        _showFailedQuery(ctx, text);
      }
      Navigator.of(ctx).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    ColorProvider colorProvider = Provider.of<ColorProvider>(context);
    final id = ModalRoute.of(context)?.settings.arguments as String? ?? '';
    final CardInfo cardInfo =
        Provider.of<CardDataProvider>(context, listen: false).getCardById(id);
    final mediaQuery = MediaQuery.of(context);
    const TextStyle textStyle = TextStyle(
      fontSize: 20,
    );
    final Settings settings = Provider.of<Settings>(context, listen: false);
    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        if (!Navigator.canPop(context)) {
          NavigationHelper.showExitAppDialog(context);
        }
      },
      child: Container(
        alignment: Alignment.topLeft,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.bottomRight,
            stops: const [0.1, 0.9],
            colors: [
              colorProvider.backgroundColor1,
              colorProvider.backgroundColor2,
            ],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            centerTitle: true,
            actions: [
              Showcase(
                key: _two,
                description:
                    "Pressing this button will search for the card in your preferred language (see settings).",
                child: getRefinedSearchButton(
                  context,
                  cardInfo,
                  ScryfallQueryMaps.inUserLanguageMap(settings.language),
                  'In ${settings.language.longName}',
                ),
              ),
              Showcase(
                key: _three,
                description:
                    "This will search for all possible prints of the card. This means, that every art version and every print in every set will be displayed. Sometimes this can make a huge difference in price!",
                child: getRefinedSearchButton(context, cardInfo,
                    ScryfallQueryMaps.printsMap, 'All Prints'),
              ),
              Showcase(
                key: _four,
                description:
                    "This will search for all possible art versions of this card. This is by definition only a subset of the results from the previous button. However, on heavily reprinted cards such as Collosal Dreadmaw this might be a better option.",
                child: getRefinedSearchButton(context, cardInfo,
                    ScryfallQueryMaps.versionMap, 'All Arts'),
              ),
            ],
          ),
          body: SizedBox(
            height: mediaQuery.size.height,
            child: Card(
              color: Colors.transparent,
              shadowColor: Colors.transparent,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Showcase(
                      key: _one,
                      description: "This is the card you searched for.",
                      child: CardDetailImageDisplay(
                          cardInfo: cardInfo, mediaQuery: mediaQuery),
                    ),
                    Showcase(
                        key: _five,
                        description:
                            "The prices are listed here again. Click the links below to reach this specific card on scryfall, Cardmarket and TCGPlayer, respectively. These links allow you to get more information on the card and better evaluate it's current price.",
                        child: CardDetails(
                            textStyle: textStyle, cardInfo: cardInfo)),
                  ],
                ),
              ),
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
            color: Theme.of(context).colorScheme.primary, fontSize: 20),
      ),
    );
  }
}
