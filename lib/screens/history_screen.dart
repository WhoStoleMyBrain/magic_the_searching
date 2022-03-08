import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/history.dart';

class HistoryScreen extends StatelessWidget {
  static const routeName = '/history-screen';
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final history = Provider.of<History>(context);
    history.setDummyData();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your past searches'),
      ),
      body: ListView.builder(
        itemCount: history.data.length,
        itemBuilder: (ctx, i) {
          return ListTile(
            // minVerticalPadding: 10.0,
            contentPadding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 24.0,),
            title: Text('Search term: ${history.data[i].query}'),
            subtitle: Text('Matches for this search: ${history.data[i].matches}'),
            onTap: () {},
          );
        },
      ),
    );
  }
}
