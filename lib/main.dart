import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:magic_the_searching/helpers/constants.dart';
import 'package:magic_the_searching/helpers/db_helper.dart';
import 'package:magic_the_searching/providers/card_symbol_provider.dart';
import 'package:magic_the_searching/providers/color_provider.dart';
import 'package:magic_the_searching/providers/image_taken_provider.dart';
import 'package:magic_the_searching/providers/settings.dart';
import 'package:magic_the_searching/screens/about_screen.dart';
import 'package:magic_the_searching/screens/help_screen.dart';
import 'package:magic_the_searching/screens/privacy_policy_page.dart';
import 'package:magic_the_searching/screens/search_page.dart';
import 'package:magic_the_searching/screens/settings_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import './providers/handedness.dart';
import './providers/card_data_provider.dart';
import './providers/history.dart';
import './screens/card_detail_screen.dart';
import './screens/card_search_screen.dart';
import './screens/history_screen.dart';
import 'providers/scryfall_provider.dart';
import 'screens/camera_screen.dart';

late List<CameraDescription> _cameras;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<void> cleanDB() async {
    final prefs = await SharedPreferences.getInstance();

    DateTime today = DateTime.now();
    int timestamp = prefs.getInt('lastDbCleaned') ??
        today.subtract(const Duration(days: 100)).millisecondsSinceEpoch;
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    if (today.difference(dateTime).inDays > 7) {
      await DBHelper.cleanDB();
      await prefs.setInt('lastDbCleaned', today.millisecondsSinceEpoch);
    }
  }

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
        ChangeNotifierProvider(
          create: (_) {
            Settings settings =
                Settings(false, false, DateTime.now(), false, Languages.en);
            settings.getUserLanguage();
            return settings;
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            CardSymbolProvider cardSymbolProvider = CardSymbolProvider();
            cardSymbolProvider.getAllAssetImages();
            return cardSymbolProvider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            ScryfallProvider scryfallProvider = ScryfallProvider();
            scryfallProvider.init();
            return scryfallProvider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            return ImageTakenProvider('', [], [], 'en');
          },
        ),
        ChangeNotifierProvider(
          lazy: false,
          create: (_) {
            ColorProvider colorProvider = ColorProvider();
            colorProvider.init();
            return colorProvider;
          },
        )
      ],
      child: Builder(builder: (context) {
        Settings settings = Provider.of<Settings>(context, listen: false);
        settings.checkCanUpdateDB();
        settings.checkUseImagesFromNet();

        return MaterialApp(
            title: 'Magic The Searching',
            theme: ThemeData(
              primarySwatch: Colors.blueGrey,
            ),
            routes: {
              CardDetailScreen.routeName: (ctx) => ShowCaseWidget(
                    onFinish: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setBool(Constants.tutorialCardDetailSeen, true);
                    },
                    builder: Builder(builder: (context) {
                      return const CardDetailScreen();
                    }),
                  ),
              HistoryScreen.routeName: (ctx) => ShowCaseWidget(
                    onFinish: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setBool(Constants.tutoriaHistorySeen, true);
                    },
                    builder: Builder(builder: (context) {
                      return const HistoryScreen();
                    }),
                  ),
              SettingsScreen.routeName: (ctx) => ShowCaseWidget(
                    onFinish: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setBool(Constants.tutorialSettingsSeen, true);
                    },
                    builder: Builder(builder: (context) {
                      return const SettingsScreen();
                    }),
                  ),
              HelpScreen.routeName: (ctx) => const HelpScreen(),
              CameraScreen.routeName: (ctx) => ShowCaseWidget(
                    onFinish: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setBool(Constants.tutorialImageTakenSeen, true);
                    },
                    builder: Builder(builder: (context) {
                      return CameraScreen(_cameras);
                    }),
                  ),
              PrivacyPolicyPage.routeName: (ctx) => const PrivacyPolicyPage(),
              AboutScreen.routeName: (ctx) => const AboutScreen(),
              SearchPage.routeName: (ctx) => ShowCaseWidget(
                    onFinish: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setBool(Constants.tutorialSearchMaskSeen, true);
                    },
                    builder: Builder(builder: (context) {
                      return const SearchPage();
                    }),
                  )
            },
            home: ShowCaseWidget(
              onFinish: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setBool(Constants.tutorialSeen, true);
              },
              builder: Builder(builder: (context) => const CardSearchScreen()),
            ));
      }),
    );
  }
}
