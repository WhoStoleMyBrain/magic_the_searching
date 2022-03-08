import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './providers/handedness.dart';
import './screens/card_detail_screen.dart';
import './providers/card_data_provider.dart';
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
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
        ),
        routes: {
          CardDetailScreen.routeName: (ctx) => const CardDetailScreen(),
        },
        home: const CardSearchScreen(),
      ),
    );
  }
}
