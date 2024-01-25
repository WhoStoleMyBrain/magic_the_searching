import 'package:flutter/material.dart';
import 'package:magic_the_searching/helpers/scryfall_query_maps.dart';
import 'package:magic_the_searching/providers/card_data_provider.dart';
import 'package:magic_the_searching/widgets/app_drawer.dart';
import 'package:provider/provider.dart';
import '../helpers/search_start_helper.dart';
import '../providers/history.dart';

class HistoryScreen extends StatefulWidget {
  static const routeName = '/history-screen';
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool isInit = false;

  void setInitToTrue() {
    setState(() {
      isInit = true;
    });
  }

  @override
  void initState() {
    super.initState();
    if (!isInit) {
      final history = Provider.of<History>(context, listen: false);
      setState(() {
        history.getDBData(setInitToTrue);
      });
    }
  }

  void _selectHistoryItem(
      History history, CardDataProvider cardDataProvider, int index) async {
    HistoryObject thisHistoryObject = history.data[index];
    String searchText = thisHistoryObject.query;
    List<String> languages = thisHistoryObject.languages;
    cardDataProvider.query = searchText;
    cardDataProvider.isStandardQuery = true;
    cardDataProvider.languages = languages;
    // cardDataProvider.dbHelperFunction = DBHelper.getHistoryData;
    cardDataProvider.queryParameters = ScryfallQueryMaps.searchMap;
    Navigator.of(context).pushReplacementNamed('/');
    await cardDataProvider.processQuery();
  }

  void _selectHistoryItemAndOpenInput(
      History history, CardDataProvider cardDataProvider, int index) async {
    HistoryObject thisHistoryObject = history.data[index];
    String searchText = thisHistoryObject.query;
    List<String> languages = thisHistoryObject.languages;
    cardDataProvider.query = searchText;
    cardDataProvider.isStandardQuery = true;
    cardDataProvider.languages = languages;
    cardDataProvider.queryParameters = ScryfallQueryMaps.searchMap;
    SearchStartHelper.prefillValue = history.data[index].query;
    history.openModalSheet = true;
    Navigator.of(context).pushReplacementNamed('/');
    await cardDataProvider.processQuery();
  }

  @override
  Widget build(BuildContext context) {
    final history = Provider.of<History>(context);
    final cardDataProvider =
        Provider.of<CardDataProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your past searches'),
      ),
      drawer: const AppDrawer(),
      body: !isInit
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : history.data.isEmpty
              ? const Center(
                  child: Text(
                      'No data found in history. \nSearches are saved here for 7 days.'))
              : ListView.builder(
                  itemCount: history.data.length,
                  itemBuilder: (ctx, i) {
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 4.0,
                        horizontal: 24.0,
                      ),
                      title: history.data[i].query == ''
                          ? const Text('*No Query*')
                          : Text(
                              'Search term: ${history.data[i].query[0] == '!' ? history.data[i].query.substring(1) : history.data[i].query}'),
                      subtitle: Text(
                          'Matches for this search: ${history.data[i].matches}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.mode),
                            color: Colors.black,
                            onPressed: () async {
                              _selectHistoryItemAndOpenInput(
                                  history, cardDataProvider, i);
                            },
                          ),
                          Text(
                              '${history.data[i].dateTime.year}-${history.data[i].dateTime.month < 10 ? '0' : ''}${history.data[i].dateTime.month}-${history.data[i].dateTime.day < 10 ? '0' : ''}${history.data[i].dateTime.day}'),
                        ],
                      ),
                      onTap: () {
                        _selectHistoryItem(history, cardDataProvider, i);
                      },
                    );
                  },
                ),
    );
  }
}
