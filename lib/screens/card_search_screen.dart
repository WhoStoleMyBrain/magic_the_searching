import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../helpers/scryfall_request_handler.dart';
import '../models/card_data.dart';
import '../screens/card_detail_screen.dart';
import '../widgets/card_display.dart';
import '../widgets/enter_search_term.dart';
import '../providers/card_data_provider.dart';

class CardSearchScreen extends StatelessWidget {
  const CardSearchScreen({Key? key}) : super(key: key);

  void cardTapped(BuildContext ctx, String id) {
    Navigator.of(ctx).pushNamed(CardDetailScreen.routeName, arguments: id);
  }

  void _startEnterSearchTerm(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (bCtx) {
        return GestureDetector(
          onTap: () {},
          child: EnterSearchTerm(
            startSearchForCard: (text) {
              return _startSearchForCard(ctx, text);
            },
          ),
          // behavior: HitTestBehavior.opaque,
        );
      },
    );
  }

  Future<void> _showFailedQuery(BuildContext ctx, String query) async {
    return showDialog<void>(
      context: ctx,
      builder: (bCtx) {
        return AlertDialog(
          title: const Text('No results found'),
          content: SingleChildScrollView(child: Text('No results matching \'$query\' found.')),
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

  Future<void> _startSearchForCard(BuildContext ctx, String text) async {
    final cardDataProvider = Provider.of<CardDataProvider>(ctx, listen: false);
    final scryfallRequestHandler = ScryfallRequestHandler(searchText: text);
    scryfallRequestHandler.translateTextToQuery();
    await scryfallRequestHandler.sendQueryRequest();
    final queryResult = scryfallRequestHandler.processQueryData();
    if (queryResult.isEmpty) {
      _showFailedQuery(ctx, text);
    }
    cardDataProvider.cards = queryResult;
  }

  @override
  Widget build(BuildContext context) {
    final cardDataProvider = Provider.of<CardDataProvider>(context);
    // Future.delayed(Duration.zero, () {
    //   cardDataProvider.setDummyData();
    // });

    // final mediaQuery = MediaQuery.of(context);
    final appBar = AppBar(
      title: const Text('Search for cards...'),
    );
    return Scaffold(
      appBar: appBar,
      body: cardDataProvider.cards.length <= 0
          ? const Center(child: Text('No cards found. Try searching for some!'))
          : GridView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2 / 4,
                // mainAxisExtent: 1,
              ),
              itemCount: cardDataProvider.cards.length,
              itemBuilder: (ctx, index) {
                return CardDisplay(
                  cardData: cardDataProvider.cards[index],
                  cardTapped: cardTapped,
                );
              },
            ),
      floatingActionButton: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: FloatingActionButton(
                heroTag: 'search',
                onPressed: () => _startEnterSearchTerm(context),
                child: const Icon(Icons.search),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(5.0),
              child: FloatingActionButton(
                heroTag: 'camera',
                onPressed: null,
                child: Icon(Icons.camera_enhance),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
