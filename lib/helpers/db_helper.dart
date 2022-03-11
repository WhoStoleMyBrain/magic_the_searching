import 'package:magic_the_searching/models/card_data.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;

class DBHelper {
  static Future<sql.Database> database() async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(path.join(dbPath, 'searches.db'),
        onCreate: (db, version) async {
      await db.execute(
          'CREATE TABLE user_searches(searchText TEXT, id TEXT PRIMARY KEY, name TEXT, text TEXT, hasTwoSides BIT, requestTime DATETIME, isFromVersions BIT)');
      await db.execute(
          'CREATE TABLE search_images(searchText TEXT, id TEXT PRIMARY KEY, frontImage TEXT, backImage TEXT, requestTime DATETIME)');
      await db.execute(
          'CREATE TABLE search_prices(searchText TEXT, id TEXT PRIMARY KEY, tcg TEXT, tcgFoil TEXT, cdm TEXT, cdmFoil TEXT, requestTime DATETIME)');
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
    db.insert('user_searches', data["user_searches"] ?? {},
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    db.insert('search_images', data["search_images"] ?? {},
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    db.insert('search_prices', data["search_prices"] ?? {},
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, dynamic>>> getData(String table, String column, String searchText, ) async {
    final db = await DBHelper.database();
    return db.query(table, where: '$column = ?', whereArgs: [searchText]);
  }

  static Future<List<Map<String, dynamic>>> getHistoryData() async {
    final db = await DBHelper.database();
    var history = await db.rawQuery('SELECT searchText, COUNT(*) as count, requestTime from user_searches GROUP BY searchText ORDER BY requestTime DESC');
    return history;
  }

  static Future<List<Map<String, dynamic>>> getVersionsOrPrintsData() async {
    final db = await DBHelper.database();
    var history = await db.rawQuery('SELECT name, searchText FROM user_searches WHERE user_searches.name = user_searches.searchText AND isFromVersions = 1');
    return history;
  }

  // static Future<List<Map<String, dynamic>>> getVersions(String table, String searchText) async {
  //   final db = await DBHelper.database();
  //   return db.query(table, where: 'name = ?', whereArgs: [searchText]);
  // }

  static Future<void> cleanDB() async {
    final db = await DBHelper.database();
    await db.execute("DELETE FROM search_images WHERE requestTime <= datetime('now', '-7 day')");
    await db.execute("DELETE FROM search_prices WHERE requestTime <= datetime('now', '-7 day')");
    await db.execute("DELETE FROM user_searches WHERE requestTime <= datetime('now', '-7 day')");
  }

}
