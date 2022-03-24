import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:magic_the_searching/helpers/bulk_data_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/settings.dart';
import '../scryfall_api_json_serialization/bulk_data.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);
  static const routeName = '/settings-screen';
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _total = 0, _received = 0;
  late http.StreamedResponse _response;
  File? _file;
  bool isInit = false;

  Future<BulkData?> _downloadData(BulkData? bulkData) async {
    final List<int> _bytes = [];
    _response = await http.Client()
        .send(http.Request('GET', Uri.parse(bulkData?.downloadUri ?? '')));
    _total = _response.contentLength ?? 0;
    _response.stream.listen((value) {
      setState(() {
        _bytes.addAll(value);
        _received += value.length;
      });
    }).onDone(() async {
      await saveBytesToFile(_bytes)
          .whenComplete(() => setPreferences(bulkData))
          .whenComplete(() => _saveDataToDB());
    });
    return bulkData;
  }

  Future<void> saveBytesToFile(List<int> bytes) async {
    final file = File(
        '${(await getApplicationDocumentsDirectory()).path}/myBulkData.txt');
    await file.writeAsBytes(bytes);
    setState(() {
      _file = file;
    });
  }

  Future<void> handleBulkData() async {
    setState(() {
      _total = 0;
      _received = 0;
    });
    BulkData? bulkData = await BulkDataHelper.getBulkData();
    await _downloadData(bulkData);
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
    await BulkDataHelper.writeBulkDataToDB(jsonList);
  }

  Future<void> deleteLocalFile() async {
    await _file?.delete();
    _file = null;
  }

  Future<void> onDBValueChange(bool newValue) async {
    final settings = Provider.of<Settings>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('useLocalDB', newValue);
    settings.useLocalDB = newValue;
  }

  Future<void> checkIfCanUpdateDB(Settings settings) async {
    if (!isInit) {
      settings.checkCanUpdateDB();
      isInit = true;
    }
  }
  // floatingActionButton: FloatingActionButton.extended(
  // label:
  // Text('${_received ~/ (1024 * 1024)}/${_total ~/ (1024 * 1024)} MB'),
  // icon: const Icon(Icons.file_download),
  // onPressed: handleBulkData,
  // ),

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<Settings>(context);
    checkIfCanUpdateDB(settings);
    bool useLocalDB = settings.useLocalDB;
    bool canUpdateDB = settings.canUpdateDB;
    DateTime dbDate = settings.dbDate;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          TextButton(
              onPressed: () {
                setState(() {
                  isInit = false;
                });
              },
              child: const Text(
                'check bulk date',
                style: TextStyle(color: Colors.black),
              ))
        ],
      ),
      body: Column(
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
                  onDBValueChange(newValue);
                },
              ),
            ],
          ),
          Column(
            children: [
              ElevatedButton(
                onPressed: canUpdateDB
                    ? () {
                        handleBulkData();
                      }
                    : null,
                child: canUpdateDB
                    ? const Text('Refresh local DB')
                    : const Text('DB up to date'),
              ),
              Text(
                'last updated: ${dbDate.year}-${dbDate.month.toString().length < 2 ? '0${dbDate.month}' : dbDate.month}-${dbDate.day.toString().length < 2 ? '0${dbDate.day}' : dbDate.day}',
                //   'last updated: ${dbDate.toLocal(}',
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                  '${_received ~/ (1024 * 1024)}/${_total ~/ (1024 * 1024)} MB'),
            ],
          ),
        ],
      ),
    );
  }
}
