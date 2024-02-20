import 'dart:io';

import 'package:magic_the_searching/helpers/constants.dart';
import 'package:magic_the_searching/providers/history.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;

class DBHelper {
  static final DBHelper _dbHelper = DBHelper._internal();
  factory DBHelper() {
    return _dbHelper;
  }
  DBHelper._internal();

  static Future<void> deleteTablesIfExists() async {
    final db = await DBHelper.cardDatabase();
    await db.execute('DROP TABLE IF EXISTS card_info');
    await db.execute('DROP TABLE IF EXISTS card_detail');
    await db.execute('DROP TABLE IF EXISTS image_uris');
    await db.execute('DROP TABLE IF EXISTS card_faces');
    await db.execute('DROP TABLE IF EXISTS prices');
    await db.execute('DROP TABLE IF EXISTS purchase_uris');
    // Make sure that the tables are there, since we manually deleted them.
    // Therefore onCreate on the database would not be called again, which
    // in turn results in an empty database
    await recreateTablesIfTheyDoNotExist();
  }

  static Future<void> recreateTablesIfTheyDoNotExist() async {
    final db = await DBHelper.cardDatabase();
    await db.execute(Constants.createCardInfoTable);
    await db.execute(Constants.createCardDetailTable);
    await db.execute(Constants.createImageUrisTable);
    await db.execute(Constants.createCardFacesTable);
    await db.execute(Constants.createPricesTable);
    await db.execute(Constants.createPurchaseUrisTable);
  }

  static Future<int> checkDatabaseSize(String dbName) async {
    try {
      final dbPath = await sql.getDatabasesPath();
      String fullDbPath = path.join(dbPath, dbName);
      final file = File(fullDbPath);
      final size = await file.length();
      return size;
    } on PathNotFoundException {
      return await cardDatabase().then((value) async {
        return await value.close().then((value) async {
          final dbPath = await sql.getDatabasesPath();
          String fullDbPath = path.join(dbPath, dbName);

          final file = File(fullDbPath).openRead();
          final size = await file.length;
          return size;
        });
      });
    }
  }

  static Future<void> deleteDatabaseFile(String dbName) async {
    final dbPath = await sql.getDatabasesPath();
    String fullDbPath = path.join(dbPath, dbName);
    final file = File(fullDbPath);
    await file.delete();
  }

  static Future<sql.Database> cardDatabase() async {
    final dbPath = await sql.getDatabasesPath();
    return sql
        .openDatabase(path.join(dbPath, Constants.cardDatabaseTableFileName),
            onCreate: (db, version) async {
      await db.execute(Constants.createCardInfoTable);
      await db.execute(Constants.createCardDetailTable);
      await db.execute(Constants.createImageUrisTable);
      await db.execute(Constants.createCardFacesTable);
      await db.execute(Constants.createPricesTable);
      await db.execute(Constants.createPurchaseUrisTable);
    }, version: 1);
  }

  static Future<void> insertIntoCardDatabase(Map<String, dynamic> data) async {
    final db = await DBHelper.cardDatabase();
    db.insert('card_info', data["card_info"] ?? {},
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    db.insert('card_detail', data["card_detail"] ?? {},
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    db.insert('image_uris', data["image_uris"] ?? {},
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    db.insert('card_faces', data["card_faces"] ?? {},
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    db.insert('prices', data["prices"] ?? {},
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    db.insert('purchase_uris', data["purchase_uris"] ?? {},
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  static Future<void> insertBulkDataIntoCardDatabase(
      List<Map<String, dynamic>> dataList) async {
    final db = await DBHelper.cardDatabase();
    var batch = db.batch();
    for (Map<String, dynamic> data in dataList) {
      batch.insert('card_info', data["card_info"] ?? {},
          conflictAlgorithm: sql.ConflictAlgorithm.replace,
          nullColumnHack: 'id');
      batch.insert('card_detail', data["card_detail"] ?? {},
          conflictAlgorithm: sql.ConflictAlgorithm.replace,
          nullColumnHack: 'id');
      batch.insert('image_uris', data["image_uris"] ?? {},
          conflictAlgorithm: sql.ConflictAlgorithm.replace,
          nullColumnHack: 'id');
      batch.insert('card_faces', data["card_faces"] ?? {},
          conflictAlgorithm: sql.ConflictAlgorithm.replace,
          nullColumnHack: 'id');
      batch.insert('prices', data["prices"] ?? {},
          conflictAlgorithm: sql.ConflictAlgorithm.replace,
          nullColumnHack: 'id');
      batch.insert('purchase_uris', data["purchase_uris"] ?? {},
          conflictAlgorithm: sql.ConflictAlgorithm.replace,
          nullColumnHack: 'id');
    }
    await batch.commit(noResult: true);
  }

  static Future<Map<String, dynamic>> getCardById(String id) async {
    final db = await DBHelper.cardDatabase();
    final cardInfo = db.query('card_info', where: 'id = ?', whereArgs: [id]);
    final cardDetail =
        db.query('card_detail', where: 'id = ?', whereArgs: [id]);
    final imageUris = db.query('image_uris', where: 'id = ?', whereArgs: [id]);
    final cardFaces = db.query('card_faces', where: 'id = ?', whereArgs: [id]);
    final prices = db.query('prices', where: 'id = ?', whereArgs: [id]);
    final purchaseUris =
        db.query('purchase_uris', where: 'id = ?', whereArgs: [id]);
    return {
      'card_info': cardInfo,
      'card_detail': cardDetail,
      'image_uris': imageUris,
      'card_faces': cardFaces,
      'prices': prices,
      'purchase_uris': purchaseUris
    };
  }

  static Future<Map<String, dynamic>> getCardByName(String name) async {
    final db = await DBHelper.cardDatabase();
    List<Map<String, dynamic>> cardInfo =
        await db.rawQuery('SELECT * FROM card_info WHERE name LIKE \'$name\'');
    if (cardInfo.isEmpty) {
      return {};
    }
    final String id = cardInfo.first["id"];
    final cardDetail =
        await db.query('card_detail', where: 'id = ?', whereArgs: [id]);
    final imageUris =
        await db.query('image_uris', where: 'id = ?', whereArgs: [id]);
    final cardFaces =
        await db.query('card_faces', where: 'id = ?', whereArgs: [id]);
    final prices = await db.query('prices', where: 'id = ?', whereArgs: [id]);
    final purchaseUris =
        await db.query('purchase_uris', where: 'id = ?', whereArgs: [id]);
    return {
      'card_info': cardInfo.first,
      'card_detail': cardDetail,
      'image_uris': imageUris.first,
      'card_faces': cardFaces.first,
      'prices': prices.first,
      'purchase_uris': purchaseUris.first,
    };
  }

  static Future<List<Map<String, dynamic>>> getCardsByName(String name) async {
    final db = await DBHelper.cardDatabase();
    List<Map<String, dynamic>> cardDetail = await db
        .rawQuery('SELECT * FROM card_detail WHERE name LIKE \'%$name%\'');
    if (cardDetail.isEmpty) {
      return [];
    }

    final List<Map<String, dynamic>> retList = [];
    for (int i = 0; i < cardDetail.length; i++) {
      // print(_cardInfo[i]);
      final String id = cardDetail[i]["id"];
      // retList.add(await DBHelper.getCardById(id));
      final cardInfo =
          await db.query('card_info', where: 'id = ?', whereArgs: [id]);
      final imageUris =
          await db.query('image_uris', where: 'id = ?', whereArgs: [id]);
      final cardFaces =
          await db.query('card_faces', where: 'id = ?', whereArgs: [id]);
      final prices = await db.query('prices', where: 'id = ?', whereArgs: [id]);
      final purchaseUris =
          await db.query('purchase_uris', where: 'id = ?', whereArgs: [id]);
      retList.add({
        'card_info': cardInfo,
        'card_detail': cardDetail[i],
        'image_uris': imageUris.first,
        'card_faces': cardFaces.first,
        'prices': prices.first,
        'purchase_uris': purchaseUris.first,
      });
    }
    return retList;
  }

  static Future<sql.Database> historyDatabase() async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(path.join(dbPath, 'history.db'),
        onCreate: (db, version) async {
      await db.execute(
          'CREATE TABLE search_history(searchText TEXT UNIQUE PRIMARY KEY, matches INTEGER, dateTime DATETIME, languages STRING);');
    }, version: 1);
  }

  static Future<void> insertIntoHistory(Map<String, dynamic>? data) async {
    final db = await DBHelper.historyDatabase();
    db.insert('search_history', data ?? {},
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  static Future<List<HistoryObject>> getHistoryData() async {
    final db = await DBHelper.historyDatabase();
    var history = await db
        .rawQuery('SELECT * from search_history ORDER BY dateTime DESC');
    return history.map((e) => HistoryObject.fromDB(e)).toList();
  }

  static Future<void> cleanDB() async {
    final db = await DBHelper.historyDatabase();
    await db.execute(
        "DELETE FROM search_history WHERE dateTime <= datetime('now', '-7 day')");
  }
}
