import 'package:flutter/material.dart';
import 'package:magic_the_searching/helpers/db_helper.dart';
import 'package:magic_the_searching/providers/card_data_provider.dart';
import 'package:magic_the_searching/screens/card_search_screen.dart';
import 'package:provider/provider.dart';
import '../models/card_data.dart';
import '../providers/history.dart';

class HistoryScreen extends StatefulWidget {
  static const routeName = '/history-screen';
  HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool isInit = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isInit) {
      final history = Provider.of<History>(context, listen: false);
      // history.setDummyData();
      setState(() {
        history.getDBData();
        isInit = !isInit;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final history = Provider.of<History>(context);
    final cardDataProvider =
        Provider.of<CardDataProvider>(context, listen: false);
    // history.setDummyData();
    // history.getDBData();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your past searches'),
      ),
      body: ListView.builder(
        itemCount: history.data.length,
        itemBuilder: (ctx, i) {
          return ListTile(
            // minVerticalPadding: 10.0,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 4.0,
              horizontal: 24.0,
            ),
            title: Text('Search term: ${history.data[i].query}'),
            subtitle:
                Text('Matches for this search: ${history.data[i].matches}'),
            onTap: () async {
              String searchText = history.data[i].query;
              var dbData = {
                'user_searches':
                    await DBHelper.getData('user_searches', searchText),
                'search_images':
                    await DBHelper.getData('search_images', searchText),
                'search_prices':
                    await DBHelper.getData('search_prices', searchText),
              };
              // var dbData = await DBHelper.getData('user_searches', searchText);
              // print(dbData);
              List<CardData> myData = [];
              // print(dbData['user_searches']?[0]);
              for (int i = 0; i < dbData['user_searches']!.length; i++) {
                myData.add(
                  CardData.fromMap(
                    {
                      'user_searches': dbData['user_searches']?[i] ?? {},
                      'search_images': dbData['search_images']?[i] ?? {},
                      'search_prices': dbData['search_prices']?[i] ?? {},
                    },
                  ),
                );
              }
              print(myData[0].name);
              cardDataProvider.cards = myData;
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
