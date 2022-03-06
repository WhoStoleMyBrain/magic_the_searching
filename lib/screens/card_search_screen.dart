import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/card_detail_sreen.dart';
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
          child: EnterSearchTerm(),
          behavior: HitTestBehavior.opaque,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardDataProvider = Provider.of<CardDataProvider>(context);
    Future.delayed(Duration.zero, () {
      cardDataProvider.setDummyData();
    });

    final mediaQuery = MediaQuery.of(context);
    final appBar = AppBar(
      title: const Text('Search for cards...'),
    );
    return Scaffold(
      appBar: appBar,
      body: GridView.builder(
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
                onPressed: () => _startEnterSearchTerm(context),
                child: const Icon(Icons.search),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(5.0),
              child: FloatingActionButton(
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
