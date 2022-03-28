import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:magic_the_searching/helpers/bulk_data_helper.dart';
import 'package:magic_the_searching/helpers/db_helper.dart';
import 'package:magic_the_searching/widgets/app_drawer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/settings.dart';
import '../scryfall_api_json_serialization/bulk_data.dart';
import '../scryfall_api_json_serialization/card_info.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);
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
  bool _isSavingToLocalFile = false;
  bool _isProcessingToLocalDB = false;

  Future<BulkData?> _downloadData(BulkData? bulkData) async {
    final List<int> _bytes = [];
    _response = await http.Client()
        .send(http.Request('GET', Uri.parse(bulkData?.downloadUri ?? '')));
    _totalBits = (_response.contentLength ?? 0) * 8;
    _response.stream.listen((value) {
      setState(() {
        _bytes.addAll(value);
        _receivedBits += value.length;
      });
    }).onDone(() async {
      setState(() {
        _isDownloading = false;
        _isSavingToLocalFile = true;
      });
      await saveBytesToFile(_bytes)
          .whenComplete(() => setPreferences(bulkData))
          .whenComplete(() => _saveDataToDB())
          .whenComplete(() => setState(() {
                _isRequestingBulkData = false;
                _isDownloading = false;
                _isSavingToLocalFile = false;
                _isProcessingToLocalDB = false;
              }));
    });
    return bulkData;
  }

  Future<void> saveBytesToFile(List<int> bytes) async {
    final file = File(
        '${(await getApplicationDocumentsDirectory()).path}/myBulkData.txt');
    await file.writeAsBytes(bytes).whenComplete(() => setState(() {
          _isSavingToLocalFile = false;
          _isProcessingToLocalDB = true;
          _file = file;
        }));
  }

  Future<void> handleBulkData() async {
    setState(() {
      _isRequestingBulkData = true;
      _totalBits = 0;
      _receivedBits = 0;
    });
    await BulkDataHelper.getBulkData().then((BulkData? bulkData) async => {
          setState(() {
            _isRequestingBulkData = false;
            _isDownloading = true;
          }),
          await _downloadData(bulkData)
        });
  }

  Future<BulkData?> setPreferences(BulkData? bulkData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'dbUpdatedAt',
        bulkData?.updatedAt.toIso8601String() ??
            DateTime.now().toIso8601String());
    return bulkData;
  }

  Future<void> _saveDataToDB() async {
    final content = await _file?.readAsString() ?? '';
    final jsonList = await jsonDecode(content);
    setState(() {
      _entriesSaved = 0;
      _totalEntries = jsonList.length;
    });
    for (int i = 0; i < jsonList.length; i += 1000) {
      try {
        setState(() {
          _entriesSaved = i;
        });
        final List tmp = jsonList.sublist(i, i + 1000);
        final List<Map<String, dynamic>> tmp2 =
            tmp.map((e) => CardInfo.fromJson(e).toDB()).toList();
        await DBHelper.insertBulkDataIntoCardDatabase(tmp2);
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

  Future<void> changeUseLocalDB(bool newValue, BuildContext ctx) async {
    // first check if local DB does exists!
    try {
      var dbSize = await DBHelper.checkDatabaseSize('cardDatabase.db');
      final settings = Provider.of<Settings>(context, listen: false);
      if (dbSize ~/ (1024 * 1024) < 3) {
        settings.useLocalDB = false;
        await showNoLocalDB(ctx);
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('useLocalDB', newValue);
        settings.useLocalDB = newValue;
      }
    } on FileSystemException {
      final settings = Provider.of<Settings>(context, listen: false);
      settings.useLocalDB = false;
      await showNoLocalDB(ctx);
    }
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

  Future<void> checkIfCanUpdateDB(Settings settings) async {
    if (!isInit) {
      settings.checkCanUpdateDB();
      isInit = true;
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
    await prefs.setBool('useImagesFromNet', newValue);
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
        automaticallyImplyLeading: (_isProcessingToLocalDB ||
                _isSavingToLocalFile ||
                _isDownloading ||
                _isRequestingBulkData)
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
                        ? () {
                            handleBulkData().whenComplete(() => setState(() {
                                  settings.checkCanUpdateDB();
                                }));
                          }
                        : null,
                    child: canUpdateDB
                        ? const Text('Refresh local DB')
                        : const Text('DB up to date'),
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
                      var dbSize =
                          await DBHelper.checkDatabaseSize('cardDatabase.db');
                      print(
                          'dbSize: $dbSize B; ${dbSize ~/ 1024} KB; ${dbSize ~/ (1024 * 1024)} MB');
                    },
                    child: const Text('Check card db file...')),
              if (kDebugMode)
                ElevatedButton(
                    onPressed: () async {
                      var dbSize =
                          await DBHelper.checkDatabaseSize('history.db');
                      print(
                          'dbSize: $dbSize B; ${dbSize ~/ 1024} KB; ${dbSize ~/ (1024 * 1024)} MB');
                    },
                    child: const Text('Check history db file...')),
            ],
          ),
          (_isRequestingBulkData ||
                  _isDownloading ||
                  _isSavingToLocalFile ||
                  _isProcessingToLocalDB)
              ? Container(
                  color: const Color.fromRGBO(197, 197, 197, 0.35),
                  height: MediaQuery.of(context).size.height * 1,
                  child: Center(
                    child: _isRequestingBulkData
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              CircularProgressIndicator(),
                              Text('Fetching Bulk Data Url...'),
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
                                ],
                              )
                            : _isSavingToLocalFile
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      CircularProgressIndicator(),
                                      Text('Saving file before processing...'),
                                    ],
                                  )
                                : _isProcessingToLocalDB
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CircularProgressIndicator(
                                            value: _totalEntries != 0
                                                ? (_entriesSaved /
                                                    _totalEntries)
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
