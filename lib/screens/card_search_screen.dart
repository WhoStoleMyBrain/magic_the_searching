import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../helpers/scryfall_request_handler.dart';
import '../providers/handedness.dart';
import '../providers/card_data_provider.dart';
import '../screens/card_detail_screen.dart';
import '../screens/history_screen.dart';
import '../widgets/card_display.dart';
import '../widgets/enter_search_term.dart';

enum HandedMode {
  left,
  right,
}

class CardSearchScreen extends StatefulWidget {
  const CardSearchScreen({Key? key}) : super(key: key);

  @override
  State<CardSearchScreen> createState() => _CardSearchScreenState();
}

class _CardSearchScreenState extends State<CardSearchScreen> {
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
          content: SingleChildScrollView(
              child: Text('No results matching \'$query\' found.')),
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
    final handednessProvider = Provider.of<Handedness>(context);
    // bool handedMode = false;
    // Future.delayed(Duration.zero, () {
    //   cardDataProvider.setDummyData();
    // });

    // final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      appBar: const MyAppBar(),
      body: cardDataProvider.cards.isEmpty
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
      floatingActionButton: MyFloatingActionButtons(
        startEnterSearchTerm: _startEnterSearchTerm,
      ),
    );
  }
}

class MyAppBar extends StatefulWidget with PreferredSizeWidget {
  const MyAppBar({Key? key}) : super(key: key);

  @override
  State<MyAppBar> createState() => _MyAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _MyAppBarState extends State<MyAppBar> {
  bool handedMode = false;

  @override
  Widget build(BuildContext context) {
    final handednessProvider = Provider.of<Handedness>(context, listen: false);
    return AppBar(
      title: handedMode ? const Text('right-handed') : const Text('left-handed'),
      actions: [
        Switch(
          value: handedMode,
          onChanged: (value) {
            setState(
              () {
                handedMode = value;
                handednessProvider.handedness = value;
              },
            );
          },
        ),
        IconButton(onPressed: () {
          Navigator.of(context).pushNamed(HistoryScreen.routeName);
        }, icon: const Icon(Icons.history)),
      ],
    );
  }
}

class MyFloatingActionButtons extends StatefulWidget {
  const MyFloatingActionButtons({Key? key, required this.startEnterSearchTerm})
      : super(key: key);
  final Function startEnterSearchTerm;

  @override
  State<MyFloatingActionButtons> createState() =>
      _MyFloatingActionButtonsState();
}

class _MyFloatingActionButtonsState extends State<MyFloatingActionButtons> {
  @override
  Widget build(BuildContext context) {
    final handednessProvider = Provider.of<Handedness>(context);
    return Container(
      padding: handednessProvider.handedness
          ? const EdgeInsets.symmetric(horizontal: 0, vertical: 0)
          : const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      child: Row(
        mainAxisAlignment: handednessProvider.handedness
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: FloatingActionButton(
              heroTag: 'search',
              onPressed: () => widget.startEnterSearchTerm(context),
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
    );
  }
}
