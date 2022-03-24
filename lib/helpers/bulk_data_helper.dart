import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:magic_the_searching/scryfall_api_json_serialization/bulk_data.dart';
import 'package:flutter/material.dart';
import '../helpers/db_helper.dart';
import '../scryfall_api_json_serialization/card_info.dart';

class BulkDataHelper {
  static const String bulkDataPath = 'https://api.scryfall.com/bulk-data';

  static Future<BulkData?> getBulkData() async {
    BulkData? bulkData;
    final url = Uri.parse(BulkDataHelper.bulkDataPath);
    final Map<String, dynamic> responseData;
    final List<dynamic> results;
    // print('trying to get bulk data json from URL');
    try {
      final response = await http.get(url);
      responseData = json.decode(response.body);
      results = responseData["data"].map((e) => BulkData.fromJson(e)).toList();
      // print('results: ${results.first.toJson()}');
      bulkData =
          results.firstWhere((element) => element.type == 'oracle_cards');
      // print(bulkData?.toJson());

      if (response.statusCode != 200) {}
    } catch (error) {
      bulkData = null;
      print(error);
    }
    return bulkData;
  }

  static Future<void> writeBulkDataToDB(List<dynamic> jsonList) async {
    print('Start writing to local DB');
    print(jsonList.length);
    for (int i = 0; i < jsonList.length; i += 1000) {
      try {
        print('Processing data $i to ${i + 999}...');
        // var lst = jsonList.sublist(i, i+999).map((e) => CardInfo.fromJson(e).toJson());
        await DBHelper.insertBulkDataIntoCardDatabase(
          jsonList
              .sublist(i, i + 999)
              .map((e) => CardInfo.fromJson(e).toDB())
              .toList(),
        );
      } catch (error) {
        print(error);
      }
    }
    // for (Map<String, dynamic> json in jsonList) {
    //   await DBHelper.insertIntoCardDatabase(CardInfo.fromJson(json).toDB());
    // }
    print('done writing to local DB');
  }
}
