import 'package:flutter/material.dart';
import 'package:magic_the_searching/helpers/constants.dart';
import 'package:magic_the_searching/helpers/scryfall_query_maps.dart';
import 'package:magic_the_searching/providers/card_data_provider.dart';
import 'package:magic_the_searching/widgets/app_drawer.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import '../helpers/navigation_helper.dart';
import '../helpers/search_start_helper.dart';
import '../providers/color_provider.dart';
import '../providers/history.dart';

class HistoryScreen extends StatefulWidget {
  static const routeName = '/history-screen';
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool isInit = false;
  bool showcaseRunning = false;

  final GlobalKey _one = GlobalKey();
  final GlobalKey _two = GlobalKey();
  final GlobalKey _three = GlobalKey();
  final GlobalKey _four = GlobalKey();
  final GlobalKey _five = GlobalKey();
  final GlobalKey _six = GlobalKey();

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
    SharedPreferences.getInstance().then((SharedPreferences prefs) {
      bool tutorialSettingsSeen =
          prefs.getBool(Constants.tutorialSettingsSeen) ?? false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        History history = Provider.of<History>(context, listen: false);
        if (!tutorialSettingsSeen &&
            history.data.isNotEmpty &&
            !showcaseRunning) {
          ShowCaseWidget.of(context)
              .startShowCase([_one, _two, _three, _four, _five, _six]);
          showcaseRunning = true;
        }
      });
    });
  }

  void _selectHistoryItem(
      History history, CardDataProvider cardDataProvider, int index) async {
    HistoryObject thisHistoryObject = history.data[index];
    String searchText = thisHistoryObject.query;
    List<Languages> languages = thisHistoryObject.languages;
    cardDataProvider.query = searchText;
    cardDataProvider.isStandardQuery = true;
    cardDataProvider.languages = languages;
    // cardDataProvider.dbHelperFunction = DBHelper.getHistoryData;
    cardDataProvider.scryfallQueryMaps = ScryfallQueryMaps.searchMap;
    Navigator.of(context).pushReplacementNamed('/');
    history.openModalSheet = false;
    await cardDataProvider.processQuery();
  }

  void _selectHistoryItemAndOpenInput(
      History history, CardDataProvider cardDataProvider, int index) async {
    HistoryObject thisHistoryObject = history.data[index];
    String searchText = thisHistoryObject.query;
    List<Languages> languages = thisHistoryObject.languages;
    cardDataProvider.query = searchText;
    cardDataProvider.isStandardQuery = true;
    cardDataProvider.languages = languages;
    cardDataProvider.scryfallQueryMaps = ScryfallQueryMaps.searchMap;
    SearchStartHelper.prefillValue = history.data[index].query;
    history.openModalSheet = true;
    Navigator.of(context).pushReplacementNamed('/');
    // await cardDataProvider.processQuery();
  }

  @override
  Widget build(BuildContext context) {
    ColorProvider colorProvider = Provider.of<ColorProvider>(context);
    final history = Provider.of<History>(context);
    final cardDataProvider =
        Provider.of<CardDataProvider>(context, listen: false);
    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        if (!Navigator.canPop(context)) {
          NavigationHelper.showExitAppDialog(context);
        }
      },
      child: Container(
        alignment: Alignment.topLeft,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.bottomRight,
            stops: const [0.1, 0.9],
            colors: [
              colorProvider.backgroundColor1,
              colorProvider.backgroundColor2,
            ],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
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
                        return i == 0
                            ? getShowcaseListTile(history, i, cardDataProvider)
                            : getGeneralListTile(history, i, cardDataProvider);
                      },
                    ),
        ),
      ),
    );
  }

  Showcase getShowcaseListTile(
      History history, int i, CardDataProvider cardDataProvider) {
    return Showcase(
        key: _one,
        description: "Each row is one of your searches in the past 7 days.",
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            vertical: 4.0,
            horizontal: 24.0,
          ),
          title: history.data[i].query == ''
              ? const Text('*No Query*')
              : Showcase(
                  key: _two,
                  targetPadding: const EdgeInsets.all(6.0),
                  description:
                      "This will show what the exact search term was. Please note, that this is in scryfall-understandable coding, so cardtype=creature will be displayed as t:Creature. \nClick any history item to re-search for that exact search term.",
                  child: Text(
                      'Search term: ${history.data[i].query[0] == '!' ? history.data[i].query.substring(1) : history.data[i].query}'),
                ),
          subtitle: Showcase(
            key: _three,
            targetPadding: const EdgeInsets.all(6.0),
            description:
                "This will show how many results the search did yield in the past.",
            child: Text('Matches for this search: ${history.data[i].matches}'),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Showcase(
                key: _four,
                targetPadding: const EdgeInsets.all(6.0),
                description:
                    "Click this button to re-open this search in the search mask.\nThen you can make adjustments to the search as needed!",
                child: IconButton(
                  icon: const Icon(Icons.mode),
                  color: Colors.black,
                  onPressed: () async {
                    _selectHistoryItemAndOpenInput(
                        history, cardDataProvider, i);
                  },
                ),
              ),
              Showcase(
                key: _five,
                targetPadding: const EdgeInsets.all(8.0),
                description:
                    "This is the day that this exact search term was last searched for.",
                child: Text(
                    '${history.data[i].dateTime.year}-${history.data[i].dateTime.month < 10 ? '0' : ''}${history.data[i].dateTime.month}-${history.data[i].dateTime.day < 10 ? '0' : ''}${history.data[i].dateTime.day}'),
              ),
            ],
          ),
          onTap: () {
            _selectHistoryItem(history, cardDataProvider, i);
          },
        ));
  }

  ListTile getGeneralListTile(
      History history, int i, CardDataProvider cardDataProvider) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        vertical: 4.0,
        horizontal: 24.0,
      ),
      title: history.data[i].query == ''
          ? const Text('*No Query*')
          : Text(
              'Search term: ${history.data[i].query[0] == '!' ? history.data[i].query.substring(1) : history.data[i].query}'),
      subtitle: Text('Matches for this search: ${history.data[i].matches}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.mode),
            color: Colors.black,
            onPressed: () async {
              _selectHistoryItemAndOpenInput(history, cardDataProvider, i);
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
  }
}
