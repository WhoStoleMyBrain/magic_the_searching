import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:magic_the_searching/providers/scryfall_provider.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final cardDataProvider = Provider.of<CardDataProvider>(context);
    final mediaQuery = MediaQuery.of(context);
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
    const cardAspectRatio = 1 / 1.4;
    const cardPriceDisplayHeight = 183; //183

    // final totalHeight = MediaQuery.of(context).size.width / cardAspectRatio;
    final totalHeight = MediaQuery.of(context).size.width / cardAspectRatio +
        cardPriceDisplayHeight;

    final childAspectRatio = MediaQuery.of(context).size.width / totalHeight;
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
}
