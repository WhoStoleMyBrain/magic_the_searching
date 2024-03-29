import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:magic_the_searching/providers/color_provider.dart';
import 'package:mailto/mailto.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:url_launcher/url_launcher.dart';

import '../helpers/constants.dart';
import '../helpers/search_start_helper.dart';
import '../helpers/navigation_helper.dart';
import '../providers/image_taken_provider.dart';
import '../providers/scryfall_provider.dart';
import '../providers/history.dart';
import '../providers/card_data_provider.dart';
import '../providers/settings.dart';
import '../widgets/card_display.dart' as card_display;
import '../widgets/app_drawer.dart';
import '../widgets/my_main_app_bar.dart';
import '../widgets/my_main_floating_action_buttons.dart';
import 'search_page.dart';

enum HandedMode {
  left,
  right,
}

class CardSearchScreen extends StatefulWidget {
  static const routeName = '/';
  const CardSearchScreen({super.key});

  @override
  State<CardSearchScreen> createState() => _CardSearchScreenState();
}

class _CardSearchScreenState extends State<CardSearchScreen> {
  final GlobalKey _one = GlobalKey();
  final GlobalKey _two = GlobalKey();
  final GlobalKey _three = GlobalKey();
  final GlobalKey _four = GlobalKey();
  final GlobalKey _five = GlobalKey();
  final GlobalKey _six = GlobalKey();
  final GlobalKey _seven = GlobalKey();

  ScrollController _controller = ScrollController();
  bool endOfScrollReached = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((SharedPreferences prefs) {
      bool tutorialSeen = prefs.getBool(Constants.tutorialSeen) ?? false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToSearchScreenAfterLoad();
        getUseLocalDB();
        if (!tutorialSeen) {
          ShowCaseWidget.of(context)
              .startShowCase([_one, _two, _three, _four, _five, _six, _seven]);
        }
      });
      _controller = ScrollController();
      _controller.addListener(_scrollListener);
      showDialogIfFirstLoaded(context);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.removeListener(_scrollListener);
    _controller.dispose();
  }

  Future<void> getUseLocalDB() async {
    final settings = Provider.of<Settings>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    bool useLocalDB = prefs.getBool('useLocalDB') ?? false;
    settings.useLocalDB = useLocalDB;
  }

  void _navigateToSearchScreenAfterLoad() async {
    History historyProvider = Provider.of<History>(context, listen: false);
    CardDataProvider cardDataProvider =
        Provider.of<CardDataProvider>(context, listen: false);
    ScryfallProvider scryfallProvider =
        Provider.of<ScryfallProvider>(context, listen: false);
    ImageTakenProvider imageTakenProvider =
        Provider.of<ImageTakenProvider>(context, listen: false);

    if (historyProvider.openModalSheet) {
      String query = cardDataProvider.query;
      Map<String, dynamic> prefilledValues =
          SearchStartHelper.mapQueryToPrefilledValues(query, scryfallProvider);
      await Navigator.of(context)
          .push(
        MaterialPageRoute(
          builder: (context) => SearchPage(
            prefilledValues: prefilledValues,
          ),
        ),
      )
          .then((value) {
        if (kDebugMode) {
          print('returned Value value history clicked: $value');
        }

        if (value != null) {
          SearchStartHelper.startSearchForCard(
            context,
            value[Constants.contextSearchTerm],
            value[Constants.contextLanguages],
            value[Constants.contextCreatureTypes],
            value[Constants.contextKeywords],
            value[Constants.contextCardTypes],
            value[Constants.contextSet],
            value[Constants.contextCmcValue],
            value[Constants.contextCmcCondition],
            value[Constants.contextManaSymbols],
          );
        }
      });
    } else if (imageTakenProvider.openModalSheet) {
      Map<String, dynamic> prefilledValues = {
        Constants.contextSearchTerm: imageTakenProvider.cardName,
        Constants.contextCreatureTypes: imageTakenProvider.creatureType,
        Constants.contextCardTypes: imageTakenProvider.cardType,
      };
      await Navigator.of(context)
          .push(
        MaterialPageRoute(
          builder: (context) => SearchPage(
            prefilledValues: prefilledValues,
          ),
        ),
      )
          .then((value) {
        if (kDebugMode) {
          print('returned Value value history clicked: $value');
        }

        if (value != null) {
          SearchStartHelper.startSearchForCard(
            context,
            value[Constants.contextSearchTerm],
            value[Constants.contextLanguages],
            value[Constants.contextCreatureTypes],
            value[Constants.contextKeywords],
            value[Constants.contextCardTypes],
            value[Constants.contextSet],
            value[Constants.contextCmcValue],
            value[Constants.contextCmcCondition],
            value[Constants.contextManaSymbols],
          );
        }
      });
    }
  }

  _scrollListener() {
    if (_controller.offset >= _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange) {
      loadDataAtEndOfScroll();
    }
  }

  Future<void> loadDataAtEndOfScroll() async {
    final cardDataProvider =
        Provider.of<CardDataProvider>(context, listen: false);
    await cardDataProvider.requestDataAtEndOfScroll();
  }

  GridView myGridView(
      MediaQueryData mediaQuery, CardDataProvider cardDataProvider) {
    double cardAspectRatio = 1 / 1.4;
    int priceDisplaySize = 12 + 12 + 3 + 16;
    int gridPadding = 20;
    int gridWidthPadding = 20 + 8; // TODO: last 20 is temporary
    int cardPriceDisplayHeight = priceDisplaySize + gridPadding;
    double totalHeight = MediaQuery.of(context).size.width / cardAspectRatio +
        cardPriceDisplayHeight;
    double childAspectRatio =
        (MediaQuery.of(context).size.width - gridWidthPadding) / totalHeight;
    return GridView.builder(
      controller: _controller,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: cardDataProvider.cards.length,
      itemBuilder: (ctx, index) {
        return card_display.CardDisplay(
          cardInfo: cardDataProvider.cards[index],
          key: UniqueKey(),
        );
      },
    );
  }

  showDialogIfFirstLoaded(BuildContext context) async {
    await SharedPreferences.getInstance().then((SharedPreferences prefs) {
      bool isFirstLoaded =
          prefs.getBool(Constants.settingIsFirstLoaded) ?? false;
      bool tutorialSeen = prefs.getBool(Constants.tutorialSeen) ?? false;
      if (isFirstLoaded && !tutorialSeen) {
        showDialog(
          context: context,
          builder: (context) {
            final mailtoLink = Mailto(
                to: [
                  'magicthesearching@gmail.com',
                ],
                subject: 'Feedback to or Problems with Magic the Searching',
                body:
                    'Enter your suggestions or a description of your errors below. Please try to be as precise as possible and feel free to append screenshots, images or links to further clarify your request! Thank you!');
            return AlertDialog(
              title: const Text('Your feedback matters!'),
              titlePadding: const EdgeInsets.all(24.0),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(32))),
              backgroundColor: Colors.blueGrey.shade200,
              content: RichText(
                  text: TextSpan(children: [
                const TextSpan(
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        overflow: TextOverflow.visible),
                    text:
                        'This app is still under development and part of my humble desire to bring high quality apps free of charge and free of those horrible ads to users!\nIf you have any suggestions for improvements or trouble while using the app, please contact me either via the google play store or via mail at: '),
                TextSpan(
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 18,
                        overflow: TextOverflow.visible),
                    text: 'magicthesearching@gmail.com',
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        launchUrl(Uri.parse(mailtoLink.toString()));
                      }),
              ])),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      prefs.setBool(Constants.settingIsFirstLoaded, false);
                    },
                    child: const Text('Understood'))
              ],
            );
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    CardDataProvider cardDataProvider = Provider.of<CardDataProvider>(context);
    MediaQueryData mediaQuery = MediaQuery.of(context);
    ColorProvider colorProvider = Provider.of<ColorProvider>(context);

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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.1, 0.3, 0.65, 0.9],
            colors: [
              colorProvider.mainScreenColor1,
              colorProvider.mainScreenColor2,
              colorProvider.mainScreenColor3,
              colorProvider.mainScreenColor4,
            ],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          key: _scaffoldKey,
          appBar: PreferredSize(
              preferredSize: const Size(double.infinity, kToolbarHeight),
              child: MyMainAppBar(
                one: _one,
                two: _two,
                three: _three,
                four: _four,
              )),
          drawer: const AppDrawer(),
          body: cardDataProvider.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 6.0,
                    color: Colors.amber,
                  ),
                )
              : cardDataProvider.cards.isEmpty
                  ? Center(
                      child: Showcase(
                        targetShapeBorder: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(32))),
                        key: _five,
                        description:
                            "In the center your search results will be displayed",
                        child: const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'No cards found.',
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Try searching for some!',
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  : myGridView(mediaQuery, cardDataProvider),
          floatingActionButton: MyMainFloatingActionButtons(
            one: _six,
            two: _seven,
          ),
        ),
      ),
    );
  }
}
