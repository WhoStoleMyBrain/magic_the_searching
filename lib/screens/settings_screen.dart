import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:magic_the_searching/helpers/bulk_data_helper.dart';
import 'package:magic_the_searching/helpers/constants.dart';
import 'package:magic_the_searching/helpers/db_helper.dart';
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

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<Settings>(context);
    checkIfCanUpdateDB(settings);
    checkIfUseImagesFromNet(settings);
    bool useLocalDB = settings.useLocalDB;
    bool canUpdateDB = settings.canUpdateDB;
    DateTime dbDate = settings.dbDate;
    bool useImagesFromNet = settings.useImagesFromNet;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        automaticallyImplyLeading:
            (_isProcessingToLocalDB || _isDownloading || _isRequestingBulkData)
                ? false
                : true,
      ),
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Use local DB'),
                  Switch(
                    value: useLocalDB,
                    onChanged: (newValue) {
                      changeUseLocalDB(newValue, context);
                    },
                  ),
                ],
              ),
              DropdownMenu(
                  initialSelection: settings.language.name,
                  onSelected: (value) async {
                    if (value != null) {
                      settings.saveUserLanguage(Languages.values.byName(value));
                    }
                  },
                  dropdownMenuEntries: Languages.values
                      .map((e) =>
                          DropdownMenuEntry(value: e.name, label: e.longName))
                      .toList()),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Show Images (requires network connection)'),
                  Switch(
                    value: useImagesFromNet,
                    onChanged: (newValue) {
                      changeUseImagesFromNet(newValue);
                    },
                  ),
                ],
              ),
              Column(
                children: [
                  ElevatedButton(
                    onPressed: canUpdateDB
                        ? () async {
                            await BulkDataHelper.getBulkData()
                                .then((value) => showDialog<bool>(
                                    context: context,
                                    builder: (bCtx) {
                                      return AlertDialog(
                                        title: const Text('Info!'),
                                        content: SingleChildScrollView(
                                            child: Text(
                                                'Downloading and processing the data may take up to a few minutes, depending on your internet speed and the model of your phone.\nIt is highly recommended to use a Wi-Fi connection to download data!\nThe downloaded file is approximately ${value?.size ?? 150} MB large.')),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              print('trying to pop with true');
                                              Navigator.pop(context, true);
                                            },
                                            child: const Text('Okay'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              () {
                                                print(
                                                    'trying to pop with false');
                                                Navigator.pop(context);
                                              };
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
                    child: canUpdateDB
                        ? const Text('Download card info')
                        : const Text('Local card info is up to date'),
                  ),
                  Text(
                    'last updated: ${dbDate.year}-${dbDate.month.toString().length < 2 ? '0${dbDate.month}' : dbDate.month}-${dbDate.day.toString().length < 2 ? '0${dbDate.day}' : dbDate.day}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              if (kDebugMode)
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
              if (kDebugMode)
                ElevatedButton(
                    onPressed: () async {
                      var dbSize =
                          await DBHelper.checkDatabaseSize('history.db');
                      if (kDebugMode) {
                        print(
                            'dbSize: $dbSize B; ${dbSize ~/ 1024} KB; ${dbSize ~/ (1024 * 1024)} MB');
                      }
                    },
                    child: const Text('Check history db file...')),
              if (kDebugMode)
                ElevatedButton(
                  onPressed: () async {
                    await DBHelper.deleteTablesIfExists();
                  },
                  child: const Text('Delete local DB!'),
                ),
            ],
          ),
          (_isRequestingBulkData || _isDownloading || _isProcessingToLocalDB)
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
                              ElevatedButton(
                                  onPressed: () {
                                    // _response.stream.
                                    if (_client != null) {
                                      _client!.close();
                                    }
                                    setBulkDataState(); // sets all values to false
                                  },
                                  child: const Text('Abort!')),
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
                                  ElevatedButton(
                                      onPressed: () {
                                        // _response.stream.
                                        if (_client != null) {
                                          _client!.close();
                                        }
                                        setBulkDataState(); // sets all values to false
                                      },
                                      child: const Text('Abort!')),
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
                                    ],
                                  )
                                : const Center(),
                  ),
                )
              : const Center(),
        ],
      ),
    );
  }
}
