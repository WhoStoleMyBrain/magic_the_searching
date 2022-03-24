import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/process_image_taking.dart';
import '../helpers/search_start_helper.dart';
import '../providers/handedness.dart';
import '../providers/card_data_provider.dart';
import '../providers/settings.dart';
import '../screens/history_screen.dart';
import '../widgets/card_display.dart' as card_display;

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

  Future<void> getUseLocalDB() async {
    final prefs = await SharedPreferences.getInstance();
    final settings = Provider.of<Settings>(context, listen: false);
    bool useLocalDB = prefs.getBool('useLocalDB') ?? false;
    settings.useLocalDB = useLocalDB;
  }
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {getUseLocalDB();});
    // getUseLocalDB();
  }

  @override
  Widget build(BuildContext context) {
    final cardDataProvider = Provider.of<CardDataProvider>(context);
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      appBar: MyAppBar(),
      body: cardDataProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : cardDataProvider.cards.isEmpty
              ? const Center(
                  child: Text('No cards found. Try searching for some!'))
              : myGridView(mediaQuery, cardDataProvider),
      floatingActionButton: const MyFloatingActionButtons(),
    );
  }

  GridView myGridView(
      MediaQueryData mediaQuery, CardDataProvider cardDataProvider) {
    return GridView.builder(
      key: UniqueKey(),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        mainAxisExtent:
            // (mediaQuery.size.height - mediaQuery.padding.top - 35) / 2,
            (mediaQuery.size.height - mediaQuery.padding.top - 15) / 2,
      ),
      itemCount: cardDataProvider.cards.length,
      itemBuilder: (ctx, index) {
        return card_display.CardDisplay(
          cardInfo: cardDataProvider.cards[index],
          key: UniqueKey(),
        );
      },
    );
  }
}

class MyAppBar extends StatefulWidget with PreferredSizeWidget {
  MyAppBar({Key? key}) : super(key: key);

  @override
  State<MyAppBar> createState() => _MyAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _MyAppBarState extends State<MyAppBar> {
  bool handedMode = false;
  late bool useLocalDB = false;
  String title = '';
  @override
  void initState() {
    // TODO: implement initState
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
  //Survival of the Fittest
  //Ornithopter
  //Kamahl, Pit Fighter

  @override
  Widget build(BuildContext context) {
    final handednessProvider = Provider.of<Handedness>(context, listen: false);
    final cardDataProvider =
        Provider.of<CardDataProvider>(context, listen: false);
    final settings = Provider.of<Settings>(context, listen: false);
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
        Switch(
          value: useLocalDB,
          onChanged: (value) {
            setState(
              () {
                useLocalDB = value;
                settings.useLocalDB = value;
              },
            );
          },
        ),
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
        IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(HistoryScreen.routeName);
            },
            icon: const Icon(Icons.history)),
      ],
    );
  }
}

class MyFloatingActionButtons extends StatefulWidget {
  const MyFloatingActionButtons({Key? key}) : super(key: key);
  @override
  State<MyFloatingActionButtons> createState() =>
      _MyFloatingActionButtonsState();
}

class _MyFloatingActionButtonsState extends State<MyFloatingActionButtons> {
  bool isBusy = false;

  @override
  void dispose() async {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final handednessProvider = Provider.of<Handedness>(context);
    return Container(
      padding: handednessProvider.handedness
          ? const EdgeInsets.symmetric(horizontal: 70, vertical: 0)
          : const EdgeInsets.symmetric(horizontal: 90, vertical: 0),
      child: Row(
        mainAxisAlignment: handednessProvider.handedness
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: FloatingActionButton(
              heroTag: 'search',
              onPressed: () => SearchStartHelper.startEnterSearchTerm(context),
              child: const Icon(Icons.search),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: FloatingActionButton(
              heroTag: 'camera',
              onPressed: () {
                ProcessImageTaking.takePictureAndFireQuery(context);
              },
              child: const Icon(Icons.camera_enhance),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: FloatingActionButton(
              heroTag: 'DB',
              onPressed: _loadDBData,
              child: const Icon(Icons.data_array),
            ),
          ),
        ],
      ),
    );
  }

  void _loadDBData() {
    final cardDataProvider =
        Provider.of<CardDataProvider>(context, listen: false);
    cardDataProvider.processFileToLocalDB();
  }
}
