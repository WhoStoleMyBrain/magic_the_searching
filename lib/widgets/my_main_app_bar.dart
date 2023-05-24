import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/search_start_helper.dart';
import '../providers/card_data_provider.dart';
import '../providers/settings.dart';

class MyMainAppBar extends StatefulWidget {
  MyMainAppBar({Key? key}) : super(key: key);

  @override
  State<MyMainAppBar> createState() => _MyMainAppBarState();

  // @override
  // Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _MyMainAppBarState extends State<MyMainAppBar> {
  bool handedMode = false;
  late bool useLocalDB = false;
  String title = '';
  @override
  void initState() {
    super.initState();
    final settings = Provider.of<Settings>(context, listen: false);
    useLocalDB = settings.useLocalDB;
  }

  void setTitle() {
    final cardDataProvider =
        Provider.of<CardDataProvider>(context, listen: true);
    setState(
      () {
        title = cardDataProvider.query.isNotEmpty
            ? (cardDataProvider.query[0] == '!'
                ? cardDataProvider.query.substring(1)
                : cardDataProvider.query)
            : '';
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardDataProvider =
        Provider.of<CardDataProvider>(context, listen: false);
    setTitle();
    return AppBar(
      title: (cardDataProvider.cards.isNotEmpty && title != '')
          ? Text(
              'Searched for: $title',
              style: const TextStyle(fontSize: 18),
              maxLines: 2,
            )
          : const Text(
              'No search performed yet',
              style: TextStyle(fontSize: 18),
            ),
      actions: [
        (cardDataProvider.cards.isNotEmpty && title != '')
            ? IconButton(
                icon: const Icon(Icons.mode),
                color: Colors.white,
                onPressed: () {
                  SearchStartHelper.prefillValue = title;
                  SearchStartHelper.startEnterSearchTerm(context);
                },
              )
            : const IconButton(
                icon: Icon(Icons.mode),
                color: Colors.grey,
                disabledColor: Colors.grey,
                onPressed: null,
              ),
      ],
    );
  }
}
