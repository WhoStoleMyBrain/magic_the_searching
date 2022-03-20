import 'package:flutter/material.dart';
import 'package:magic_the_searching/providers/card_data_provider.dart';
import 'package:provider/provider.dart';
import '../providers/history.dart';

class HistoryScreen extends StatefulWidget {
  static const routeName = '/history-screen';
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool isInit = false;

  @override
  void initState() {
    super.initState();
    // print('isInit start:$isInit');
    if (!isInit) {
      final history = Provider.of<History>(context, listen: false);
      // history.setDummyData();
      setState(() {
        history.getDBData();
        isInit = !isInit;
      });
    }
    // print('isInit end:$isInit');
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   if (!isInit) {
  //     final history = Provider.of<History>(context, listen: false);
  //     // history.setDummyData();
  //     setState(() {
  //       history.getDBData();
  //       isInit = !isInit;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final history = Provider.of<History>(context);
    final cardDataProvider =
        Provider.of<CardDataProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your past searches'),
      ),
      // body: cardDataProvider.cards.isEmpty
      body: history.data.isEmpty
          ? const Center(
              child: Text(
                  'No data found in history. \nSearches are saved here for 7 days.'))
          : ListView.builder(
              itemCount: history.data.length,
              itemBuilder: (ctx, i) {
                return ListTile(
                  // minVerticalPadding: 10.0,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 4.0,
                    horizontal: 24.0,
                  ),
                  title: Text(
                      'Search term: ${history.data[i].query[0] == '!' ? history.data[i].query.substring(1) : history.data[i].query}'),
                  subtitle: Text(
                      'Matches for this search: ${history.data[i].matches}'),
                  trailing: Text(
                      '${history.data[i].dateTime.year}-${history.data[i].dateTime.month < 10 ? '0' : ''}${history.data[i].dateTime.month}-${history.data[i].dateTime.day < 10 ? '0' : ''}${history.data[i].dateTime.day}'),
                  onTap: () async {
                    String searchText = history.data[i].query;
                    cardDataProvider.query = searchText;
                    await cardDataProvider.processSearchQuery();
                    Navigator.of(context).pop();
                    // Navigator.of(context).pushReplacementNamed('/');
                    //getData(String table, String searchText)
                  },
                );
              },
            ),
    );
  }
}
