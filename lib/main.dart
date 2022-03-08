import 'package:flutter/material.dart';
import 'package:magic_the_searching/screens/history_screen.dart';
import 'package:provider/provider.dart';
import './providers/handedness.dart';
import './providers/card_data_provider.dart';
import './providers/history.dart';
import './screens/card_detail_screen.dart';

import './screens/card_search_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
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
          HistoryScreen.routeName: (ctx) => const HistoryScreen(),
        },
        home: const CardSearchScreen(),
      ),
    );
  }
}
