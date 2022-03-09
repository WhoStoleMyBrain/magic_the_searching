import 'package:magic_the_searching/models/card_data.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;

class DBHelper {
  static Future<sql.Database> database() async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(path.join(dbPath, 'searches.db'),
        onCreate: (db, version) async {
      await db.execute(
          'CREATE TABLE user_searches(searchText TEXT, id TEXT PRIMARY KEY, name TEXT, text TEXT, hasTwoSides BIT)');
      await db.execute(
          'CREATE TABLE search_images(searchText TEXT, id TEXT PRIMARY KEY, frontImage TEXT, backImage TEXT)');
      await db.execute(
          'CREATE TABLE search_prices(searchText TEXT, id TEXT PRIMARY KEY, tcg TEXT, tcgFoil TEXT, cdm TEXT, cdmFoil TEXT)');
      // await db.execute(
      //     'CREATE TABLE user_history(id TEXT PRIMARY KEY, name TEXT, text TEXT, hasTwoSides BIT)');
      // await db.execute(
      //     'CREATE TABLE history_images(id TEXT PRIMARY KEY, frontImage TEXT, backImage TEXT)');
      // await db.execute(
      //     'CREATE TABLE history_prices(id TEXT PRIMARY KEY, tcg TEXT, tcgFoil TEXT, cdm TEXT, cdmFoil TEXT)');
    }, version: 1);
  }

  static Future<void> insert(
      String table, Map<String, Map<String, Object?>> data) async {
    final db = await DBHelper.database();
    // insert correct data into user_searches
    db.insert('user_searches', data["user_searches"] ?? {},
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    db.insert('search_images', data["search_images"] ?? {},
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    db.insert('search_prices', data["search_prices"] ?? {},
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, dynamic>>> getData(String table, String searchText) async {
    final db = await DBHelper.database();
    return db.query(table, where: 'searchText = ?', whereArgs: [searchText]);
  }

  static Future<List<Map<String, dynamic>>> getHistoryData() async {
    final db = await DBHelper.database();
    var history = await db.rawQuery('SELECT searchText, COUNT(*) as count from user_searches GROUP BY searchText');
    return history;
  }
}

// String id;
// String name;
// String text;
// List<String> images;
// bool hasTwoSides;
// Map<String, dynamic> price;
