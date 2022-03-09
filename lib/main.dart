import 'package:flutter/material.dart';
import 'package:magic_the_searching/helpers/db_helper.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './providers/handedness.dart';
import './providers/card_data_provider.dart';
import './providers/history.dart';
import './screens/card_detail_screen.dart';
import './screens/card_search_screen.dart';
import './screens/history_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  Future<void> cleanDB() async {
    final prefs = await SharedPreferences.getInstance();

    DateTime today = DateTime.now();
    // await prefs.setInt('lastDbCleaned',
    //     today.subtract(const Duration(days: 9)).millisecondsSinceEpoch);
    int timestamp = prefs.getInt('lastDbCleaned') ?? 0;
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    // print('timestamp:$timestamp');
    // print('today:${today}');
    // print(today.difference(dateTime).inDays);
    //today.difference(dateTime).inDays > 86400
    if (today.difference(dateTime).inDays > 7) {
      print('clearing db...');
      await DBHelper.cleanDB();
      await prefs.setInt('lastDbCleaned', today.millisecondsSinceEpoch);
    }
    // if (dateTime.year != today.year || dateTime.month != today.month || dateTime.day != today.day) {
    //
    // }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    cleanDB();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CardDataProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => Handedness(false),
        ),
        ChangeNotifierProvider(
          create: (_) => History(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
        ),
        routes: {
          CardDetailScreen.routeName: (ctx) => const CardDetailScreen(),
          HistoryScreen.routeName: (ctx) => HistoryScreen(),
        },
        home: const CardSearchScreen(),
      ),
    );
  }
}
