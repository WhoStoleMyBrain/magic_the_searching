import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:magic_the_searching/scryfall_api_json_serialization/bulk_data.dart';

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

}
