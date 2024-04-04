import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:magic_the_searching/helpers/bulk_data_helper.dart';
import 'package:magic_the_searching/helpers/constants.dart';
import 'package:magic_the_searching/helpers/db_helper.dart';
import 'package:magic_the_searching/helpers/navigation_helper.dart';
import 'package:magic_the_searching/providers/color_provider.dart';
import 'package:magic_the_searching/screens/color_picker_demo.dart';
import 'package:magic_the_searching/widgets/app_drawer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/settings.dart';
import '../scryfall_api_json_serialization/bulk_data.dart';
import '../scryfall_api_json_serialization/card_info.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  static const routeName = '/settings-screen';
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _totalBits = 0, _receivedBits = 0, _entriesSaved = 0, _totalEntries = 0;
  late http.StreamedResponse _response;
  File? _file;
  bool isInit = false;
  bool _isRequestingBulkData = false;
  bool _isDownloading = false;
  bool _isProcessingToLocalDB = false;
  http.Client? _client = http.Client();

  void setBulkDataState(
      {bool isRequestingBulkData = false,
      bool isDownloading = false,
      bool isProcessingToLocalDB = false}) {
    setState(() {
      _isRequestingBulkData = isRequestingBulkData;
      _isDownloading = isDownloading;
      _isProcessingToLocalDB = isProcessingToLocalDB;
    });
  }

  Future<void> _showErrorMessage(String? errorMessage) async {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error!'),
          titlePadding: const EdgeInsets.all(24.0),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(32))),
          backgroundColor: Colors.blueGrey.shade200,
          content: SingleChildScrollView(
            child: (errorMessage == null)
                ? const Text(
                    'Something went wrong while trying to download the data. If this error persists, please contact the support!')
                : Text(
                    'Something went wrong while trying to download the data. If this error persists, please contact the support! The error message received was $errorMessage'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Okay'),
            )
          ],
        );
      },
    );
  }

  Future<void> _downloadData(BulkData? bulkData) async {
    _client = http.Client();
    try {
      _response = await _client!
          .send(http.Request('GET', Uri.parse(bulkData?.downloadUri ?? '')));
    } catch (e) {
      _showErrorMessage(e.toString());
      setBulkDataState();
    }
    _totalBits = (bulkData?.size ?? 0);
    if (kDebugMode) {
      print(bulkData?.size);
    }

    IOSink file = File(
            '${(await getApplicationDocumentsDirectory()).path}/myBulkData.txt')
        .openWrite();

    _response.stream
        .map(
            _showDownloadProgress) // Adding this allows me to show progres... however this is SIGNIFICANTLY slower, like 10x or so
        .pipe(file)
        .onError((error, stackTrace) {})
        .whenComplete(() async {
      _file = File(
          '${(await getApplicationDocumentsDirectory()).path}/myBulkData.txt');
      setBulkDataState(isProcessingToLocalDB: true);
    }).whenComplete(() {
      try {
        setBulkDataTimestampPreferences(bulkData).whenComplete(() async {
          await _saveDataToDB();
        }).whenComplete(() => setBulkDataState());
      } on Exception catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
      _client!.close();
    });
  }

  List<int> _showDownloadProgress(List<int> streamInput) {
    setState(() {
      _receivedBits += streamInput.length;
    });
    return streamInput;
  }

  Future<void> handleBulkData() async {
    setBulkDataState(
      isRequestingBulkData: true,
    );
    setState(() {
      _totalBits = 0;
      _receivedBits = 0;
    });
    await BulkDataHelper.getBulkData().then((BulkData? bulkData) async {
      setBulkDataState(isDownloading: true);
      await _downloadData(bulkData);
    });
  }

  Future<BulkData?> setBulkDataTimestampPreferences(BulkData? bulkData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        Constants.settingDbUpdatedAt,
        bulkData?.updatedAt.toIso8601String() ??
            DateTime.now().toIso8601String());
    return bulkData;
  }

  Future<void> _saveDataToDB() async {
    final content = await _file?.readAsString() ?? '';
    final List<dynamic> jsonList = await jsonDecode(content) as List;
    setState(() {
      _entriesSaved = 0;
      _totalEntries = jsonList.length;
    });

    for (int i = 0; i < jsonList.length; i += 1000) {
      try {
        List<dynamic> jsonSubList;
        setState(() {
          _entriesSaved = i;
        });
        try {
          jsonSubList = jsonList.sublist(i, i + 1000);
        } on RangeError {
          jsonSubList = jsonList.sublist(i);
        }
        final List<Map<String, dynamic>> cardSubList =
            jsonSubList.map((e) => CardInfo.fromJson(e).toDB()).toList();
        await DBHelper.insertBulkDataIntoCardDatabase(cardSubList)
            .whenComplete(() {
          deleteLocalFile(); // free up the used space!
        });
      } catch (error) {
        if (kDebugMode) {
          print(error);
        }
      }
    }
  }

  Future<void> deleteLocalFile() async {
    await _file?.delete();
    _file = null;
  }

  Future<void> showNoLocalDB(BuildContext ctx) async {
    return showDialog<void>(
      context: ctx,
      builder: (bCtx) {
        return AlertDialog(
          title: const Text('Download Data first!'),
          titlePadding: const EdgeInsets.all(24.0),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(32))),
          backgroundColor: Colors.blueGrey.shade200,
          content: const SingleChildScrollView(
              child: Text(
                  'The local database file could not be found. Be sure to download the data before trying to use it.')),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(bCtx).pop();
              },
              child: const Text('Okay'),
            )
          ],
        );
      },
    );
  }

  Future<void> changeUseLocalDB(bool newValue, BuildContext ctx) async {
    final settings = Provider.of<Settings>(context, listen: false);

    await DBHelper.checkDatabaseSize(Constants.cardDatabaseTableFileName)
        .onError((error, stackTrace) async {
      if (error is FileSystemException) {
        final settings = Provider.of<Settings>(context, listen: false);
        settings.useLocalDB = false;
      } else if (error is PathNotFoundException) {
        final settings = Provider.of<Settings>(context, listen: false);
        settings.useLocalDB = false;
      }
      return 0;
    }).then((value) async {
      if (value ~/ (1024 * 1024) < 3) {
        settings.useLocalDB = false;
        await showNoLocalDB(ctx);
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(Constants.settingUseLocalDB, newValue);
        settings.useLocalDB = newValue;
      }
    });
  }

  Future<void> checkIfCanUpdateDB(Settings settings) async {
    if (!isInit) {
      settings.checkCanUpdateDB();
    }
  }

  Future<void> checkIfUseImagesFromNet(Settings settings) async {
    if (!isInit) {
      settings.checkUseImagesFromNet();
      isInit = true;
    }
  }

  Future<void> changeUseImagesFromNet(bool newValue) async {
    final settings = Provider.of<Settings>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(Constants.settingUseImagesFromNet, newValue);
    settings.useImagesFromNet = newValue;
  }

  Future<int> checkLocalDBSize() async {
    return DBHelper.checkDatabaseSize(Constants.cardDatabaseTableFileName)
        .onError((error, stackTrace) async {
      if (error is FileSystemException) {
        return 0;
      } else if (error is PathNotFoundException) {
        return 0;
      }
      return 0;
    }).then((value) async {
      return value;
    });
  }

  ListTile getListTileLanguages(Settings settings) {
    return ListTile(
      // dense: true,
      // isThreeLine: true,
      leading: const Icon(Icons.language),
      title: const Text('Language'),
      trailing: DropdownMenu(
          enableSearch: false,
          // width: MediaQuery.of(context).size.width * 0.4,
          textStyle: const TextStyle(fontSize: 12),
          initialSelection: settings.language.name,
          onSelected: (value) async {
            if (value != null) {
              settings.saveUserLanguage(Languages.values.byName(value));
            }
          },
          dropdownMenuEntries: Languages.values
              .map((e) => DropdownMenuEntry(value: e.name, label: e.longName))
              .toList()),
    );
  }

  ListTile getListTileDownloadBulkData(DateTime dbDate, bool canUpdateDB,
      BuildContext context, Settings settings) {
    return ListTile(
      leading: const Icon(Icons.download),
      title: const Text('Download database for offline use'),
      subtitle: getBulkDataInfo(dbDate),
      trailing: getCardInfoDownloadButton(canUpdateDB, context, settings),
      // ],
    );
  }

  ListTile getListTileFreeUpStorage() {
    return ListTile(
        leading: const Icon(Icons.delete),
        title: const Text('Card info stored on device'),
        subtitle: FutureBuilder(
          future: checkLocalDBSize(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              return Text(
                  'takes up approx. MB: ${snapshot.data! / 1024 ~/ 1024}');
            }
            return const Text('takes up approx. MB:');
          },
        ),
        trailing: ElevatedButton(
            onPressed: () async {
              await DBHelper.deleteTablesIfExists();
              await setDbUpdatedAtTimestamp();
              setState(() {});
            },
            child: const Text('Delete')));
  }

  ListTile getListTileShowImages(bool useImagesFromNet) {
    return ListTile(
      // mainAxisAlignment: MainAxisAlignment.center,
      // children: [
      leading: const Icon(Icons.settings),
      title: const Text('Show Images'),
      subtitle: const Text('This uses up more internet volume'),
      trailing: Switch(
        value: useImagesFromNet,
        onChanged: (newValue) {
          changeUseImagesFromNet(newValue);
        },
      ),
      // ],
    );
  }

  ListTile getListTileUseLocalDb(bool useLocalDB, BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.dataset),
      title: const Text('Use local DB'),
      trailing: Switch(
        value: useLocalDB,
        onChanged: (newValue) {
          changeUseLocalDB(newValue, context);
        },
      ),
    );
  }

  Future<void> setDbUpdatedAtTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        Constants.settingDbUpdatedAt, Constants.defaultTimestamp);
  }

  Text getBulkDataInfo(DateTime dbDate) {
    return Text(
      'last updated: ${dbDate.year}-${dbDate.month.toString().length < 2 ? '0${dbDate.month}' : dbDate.month}-${dbDate.day.toString().length < 2 ? '0${dbDate.day}' : dbDate.day}',
      style: const TextStyle(fontSize: 12),
    );
  }

  ElevatedButton getCardInfoDownloadButton(
      bool canUpdateDB, BuildContext context, Settings settings) {
    return ElevatedButton(
      onPressed: canUpdateDB
          ? () async {
              await BulkDataHelper.getBulkData()
                  .then((value) => showDialog<bool>(
                      context: context,
                      builder: (bCtx) {
                        return AlertDialog(
                          title: const Text('Info!'),
                          titlePadding: const EdgeInsets.all(24.0),
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(32))),
                          backgroundColor: Colors.blueGrey.shade200,
                          content: SingleChildScrollView(
                              child: Text(
                                  '''Downloading and processing the data may take up to a few minutes, depending on your internet speed and the model of your phone.\nIt is highly recommended to use a Wi-Fi connection to download data!\nThe downloaded file is approximately ${value != null ? value.size / 1024 ~/ 1024 : 150} MB large.''')),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context, true);
                              },
                              child: const Text('Start Download'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Abort'),
                            )
                          ],
                        );
                      }))
                  .then((value) {
                if (value != null) {
                  if (value) {
                    handleBulkData().whenComplete(
                      () => setState(
                        () {
                          settings.checkCanUpdateDB();
                        },
                      ),
                    );
                  }
                }
              });
            }
          : null,
      child: canUpdateDB ? const Text('Download') : const Text('Up tp date'),
    );
  }

  ElevatedButton getAbortDownloadButton() {
    return ElevatedButton(
        onPressed: () {
          if (_client != null) {
            _client!.close();
          }
          deleteLocalFile();
          setBulkDataState(); // sets all values to false
          _totalBits = 0;
          _receivedBits = 0;
          _entriesSaved = 0;
          _totalEntries = 0;
          Navigator.pushNamed(context, SettingsScreen.routeName);
        },
        child: const Text('Abort!'));
  }

  List<Widget> getDebuggingWidgets() {
    return [
      const Divider(
        thickness: 3,
      ),
      const Text('Debugging'),
      ElevatedButton(
          onPressed: () async {
            // TODO: if database file does not exist, need to press this button TWICE, before getting a result...
            var dbSize = await DBHelper.checkDatabaseSize(
                Constants.cardDatabaseTableFileName);
            if (kDebugMode) {
              print(
                  'dbSize: $dbSize B; ${dbSize ~/ 1024} KB; ${dbSize ~/ (1024 * 1024)} MB');
            }
          },
          child: const Text('Check card db file...')),
      ElevatedButton(
          onPressed: () async {
            var dbSize = await DBHelper.checkDatabaseSize('history.db');
            if (kDebugMode) {
              print(
                  'dbSize: $dbSize B; ${dbSize ~/ 1024} KB; ${dbSize ~/ (1024 * 1024)} MB');
            }
          },
          child: const Text('Check history db file...')),
      ElevatedButton(
        onPressed: () async {
          await DBHelper.deleteTablesIfExists();
        },
        child: const Text('Delete local DB!'),
      )
    ];
  }

  Widget getBulkDataDownloadOverlay() {
    return (_isRequestingBulkData || _isDownloading || _isProcessingToLocalDB)
        ? Container(
            color: const Color.fromRGBO(197, 197, 197, 0.35),
            height: MediaQuery.of(context).size.height * 1,
            child: Center(
              child: _isRequestingBulkData
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const Text('Fetching Bulk Data Url...'),
                        getAbortDownloadButton(),
                      ],
                    )
                  : _isDownloading
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: (_receivedBits / _totalBits) < 1
                                  ? _receivedBits / _totalBits
                                  : 1,
                            ),
                            Text(
                                'Downloading data... ${_receivedBits ~/ (1024 * 1024)}/${_totalBits ~/ (1024 * 1024)} MB'),
                            getAbortDownloadButton(),
                          ],
                        )
                      : _isProcessingToLocalDB
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: _totalEntries != 0
                                      ? (_entriesSaved / _totalEntries)
                                      : 0,
                                ),
                                Text(
                                    'Processing data to local DB... $_entriesSaved / $_totalEntries done'),
                                getAbortDownloadButton(),
                              ],
                            )
                          : const Center(),
            ),
          )
        : const Center();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<Settings>(context);
    final colorProvider = Provider.of<ColorProvider>(context);
    checkIfCanUpdateDB(settings);
    checkIfUseImagesFromNet(settings);
    bool useLocalDB = settings.useLocalDB;
    bool canUpdateDB = settings.canUpdateDB;
    DateTime dbDate = settings.dbDate;
    bool useImagesFromNet = settings.useImagesFromNet;
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
            title: const Text('Settings'),
            automaticallyImplyLeading: (_isProcessingToLocalDB ||
                    _isDownloading ||
                    _isRequestingBulkData)
                ? false
                : true,
          ),
          drawer: const AppDrawer(),
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    getListTileUseLocalDb(useLocalDB, context),
                    getListTileShowImages(useImagesFromNet),
                    getListTileDownloadBulkData(
                        dbDate, canUpdateDB, context, settings),
                    getListTileFreeUpStorage(),
                    getListTileLanguages(settings),
                    ColorPickerPage(
                      startColor: colorProvider.mainScreenColor1,
                      setNewColor: ((Color newColor) {
                        setState(() {
                          colorProvider.mainScreenColor1 = newColor;
                        });
                      }),
                      colorName: "1st Main Screen",
                    ),
                    ColorPickerPage(
                      startColor: colorProvider.mainScreenColor2,
                      setNewColor: ((Color newColor) {
                        setState(() {
                          colorProvider.mainScreenColor2 = newColor;
                        });
                      }),
                      colorName: "2nd Main Screen",
                    ),
                    ColorPickerPage(
                      startColor: colorProvider.mainScreenColor3,
                      setNewColor: ((Color newColor) {
                        setState(() {
                          colorProvider.mainScreenColor3 = newColor;
                        });
                      }),
                      colorName: "3rd Main Screen",
                    ),
                    ColorPickerPage(
                      startColor: colorProvider.mainScreenColor4,
                      setNewColor: ((Color newColor) {
                        setState(() {
                          colorProvider.mainScreenColor4 = newColor;
                        });
                      }),
                      colorName: "4th Main Screen",
                    ),
                    ColorPickerPage(
                      startColor: colorProvider.appDrawerColor1,
                      setNewColor: ((Color newColor) {
                        setState(() {
                          colorProvider.appDrawerColor1 = newColor;
                        });
                      }),
                      colorName: "1st App Drawer",
                    ),
                    ColorPickerPage(
                      startColor: colorProvider.appDrawerColor2,
                      setNewColor: ((Color newColor) {
                        setState(() {
                          colorProvider.appDrawerColor2 = newColor;
                        });
                      }),
                      colorName: "2nd App Drawer",
                    ),
                    ColorPickerPage(
                      startColor: colorProvider.backgroundColor1,
                      setNewColor: ((Color newColor) {
                        setState(() {
                          colorProvider.backgroundColor1 = newColor;
                        });
                      }),
                      colorName: "1st Background",
                    ),
                    ColorPickerPage(
                      startColor: colorProvider.backgroundColor2,
                      setNewColor: ((Color newColor) {
                        setState(() {
                          colorProvider.backgroundColor2 = newColor;
                        });
                      }),
                      colorName: "2nd Background",
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          colorProvider.restoreDefaultColors();
                          setState(() {});
                        },
                        child: const Text('Restore default colors')),
                    ElevatedButton(
                        onPressed: () async {
                          colorProvider.setAllWhite();
                          setState(() {});
                        },
                        child: const Text('Set all colors white')),
                    if (kDebugMode) ...getDebuggingWidgets()
                  ],
                ),
              ),
              getBulkDataDownloadOverlay(),
            ],
          ),
        ),
      ),
    );
  }
}
