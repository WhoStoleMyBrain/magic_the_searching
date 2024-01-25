import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/history.dart';
import '../providers/card_data_provider.dart';
import '../providers/settings.dart';
import '../widgets/card_display.dart' as card_display;
import '../widgets/app_drawer.dart';
import '../widgets/my_main_app_bar.dart';
import '../widgets/my_main_floating_action_buttons.dart';

enum HandedMode {
  left,
  right,
}

class CardSearchScreen extends StatefulWidget {
  const CardSearchScreen({super.key});

  @override
  State<CardSearchScreen> createState() => _CardSearchScreenState();
}

class _CardSearchScreenState extends State<CardSearchScreen> {
  ScrollController _controller = ScrollController();
  bool endOfScrollReached = false;

  Future<void> getUseLocalDB() async {
    final settings = Provider.of<Settings>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    bool useLocalDB = prefs.getBool('useLocalDB') ?? false;
    settings.useLocalDB = useLocalDB;
  }

  void _openModalSheetAfterLoad() {
    final historyProvider = Provider.of<History>(context, listen: false);
    if (historyProvider.openModalSheet) {
      //TODO Fix this code!
      // SearchStartHelper.startEnterSearchTerm(context);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openModalSheetAfterLoad();
      getUseLocalDB();
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
    return Scaffold(
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
    );
  }

  GridView myGridView(
      MediaQueryData mediaQuery, CardDataProvider cardDataProvider) {
    const cardAspectRatio = 1 / 1.4;
    const cardPriceDisplayHeight = 183; //183

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
