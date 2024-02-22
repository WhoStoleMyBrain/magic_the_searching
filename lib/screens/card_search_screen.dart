import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:magic_the_searching/providers/scryfall_provider.dart';
import 'package:mailto/mailto.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../helpers/constants.dart';
import '../helpers/search_start_helper.dart';
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
  ScrollController _controller = ScrollController();
  bool endOfScrollReached = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> getUseLocalDB() async {
    final settings = Provider.of<Settings>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    bool useLocalDB = prefs.getBool('useLocalDB') ?? false;
    settings.useLocalDB = useLocalDB;
  }

  void _openModalSheetAfterLoad() async {
    History historyProvider = Provider.of<History>(context, listen: false);
    CardDataProvider cardDataProvider =
        Provider.of<CardDataProvider>(context, listen: false);
    ScryfallProvider scryfallProvider =
        Provider.of<ScryfallProvider>(context, listen: false);

    if (historyProvider.openModalSheet) {
      // SearchStartHelper.startEnterSearchTerm(context);
      final query = cardDataProvider.query;
      var prefilledValues =
          SearchStartHelper.mapQueryToPrefilledValues(query, scryfallProvider);
      if (kDebugMode) {
        print('query in history clicked: $query');
      }
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openModalSheetAfterLoad();
      getUseLocalDB();
      if (_scaffoldKey.currentState!.isDrawerOpen) {
        if (kDebugMode) {
          print('closing app drawer....');
        }
        _scaffoldKey.currentState?.closeDrawer();
      }
    });
    _controller = ScrollController();
    _controller.addListener(_scrollListener);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.removeListener(_scrollListener);
    _controller.dispose();
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

  @override
  Widget build(BuildContext context) {
    CardDataProvider cardDataProvider = Provider.of<CardDataProvider>(context);
    MediaQueryData mediaQuery = MediaQuery.of(context);
    Future.delayed(
      Duration.zero,
      () => showDialogIfFirstLoaded(context),
    );

    return PopScope(
      onPopInvoked: (didPop) {
        if (kDebugMode) {
          print('did pop: $didPop');
          print(_scaffoldKey.currentState!.isDrawerOpen);
        }
        if (_scaffoldKey.currentState!.isDrawerOpen) {
          if (kDebugMode) {
            print('closing app drawer....');
          }
          _scaffoldKey.currentState?.closeDrawer();
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: const PreferredSize(
            preferredSize: Size(double.infinity, kToolbarHeight),
            child: MyMainAppBar()),
        drawer: const AppDrawer(),
        body: cardDataProvider.isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : cardDataProvider.cards.isEmpty
                ? const Center(
                    child: Text('No cards found. Try searching for some!'))
                : myGridView(mediaQuery, cardDataProvider),
        floatingActionButton: const MyMainFloatingActionButtons(),
      ),
    );
  }

  GridView myGridView(
      MediaQueryData mediaQuery, CardDataProvider cardDataProvider) {
    double cardAspectRatio = 1 / 1.4;
    int cardPriceDisplayHeight = 183; //183
    // final totalHeight = MediaQuery.of(context).size.width / cardAspectRatio;
    double totalHeight = MediaQuery.of(context).size.width / cardAspectRatio +
        cardPriceDisplayHeight;
    double childAspectRatio = MediaQuery.of(context).size.width / totalHeight;
    return GridView.builder(
      controller: _controller,
      // key: UniqueKey(),
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
          prefs.getBool(Constants.settingIsFirstLoaded) ?? true;

      if (isFirstLoaded) {
        // if (isFirstLoaded) {
        showDialog(
          context: context,
          builder: (context) {
            final mailtoLink = Mailto(
                to: [
                  'magicthesearching@gmail.com',
                ],
                subject: 'Feedback or Trouble with Magic the Searching',
                body:
                    'Enter your suggestions or a description of your errors below. Please try to be as precise as possible and feel free to append screenshots, images or links to further clarify your request! Thank you!');
            return AlertDialog(
              title: const Text('Your feedback matters!'),
              content: Center(
                child: RichText(
                    text: TextSpan(children: [
                  TextSpan(
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 20),
                      text:
                          'This app is still under development and part of my humble desire to bring high quality apps free of charge and free of those horrible ads to users!\nIf you have any suggestions for improvements or trouble while using the app, please contact me either via the google play store or via mail at '),
                  TextSpan(
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 20),
                      text: 'magicthesearching@gmail.com',
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          launchUrl(Uri.parse(mailtoLink.toString()));
                        }),
                ])),
              ),
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
}
