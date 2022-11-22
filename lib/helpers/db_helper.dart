import 'dart:io';

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
    db.execute('DROP TABLE IF EXISTS card_info');
    db.execute('DROP TABLE IF EXISTS card_detail');
    db.execute('DROP TABLE IF EXISTS image_uris');
    db.execute('DROP TABLE IF EXISTS card_faces');
    db.execute('DROP TABLE IF EXISTS prices');
    db.execute('DROP TABLE IF EXISTS purchase_uris');
  }

  static Future<int> checkDatabaseSize(String dbName) async {
    final dbPath = await sql.getDatabasesPath();
    String fullDbPath = path.join(dbPath, dbName);
    final file = File(fullDbPath);
    final size = await file.length();
    return size;
  }

  static Future<sql.Database> cardDatabase() async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(path.join(dbPath, 'cardDatabase.db'),
        onCreate: (db, version) async {
      await db.execute(
          'CREATE TABLE card_info(id TEXT UNIQUE PRIMARY KEY, oracleId TEXT, scryfallUri TEXT, dateTime DATETIME);');
      await db.execute(
          'CREATE TABLE card_detail(id TEXT UNIQUE PRIMARY KEY, name TEXT, manaCost TEXT, typeLine TEXT, oracleText TEXT, power TEXT, toughness TEXT, setName TEXT, flavorText TEXT, hasTwoSides INTEGER, FOREIGN KEY(id) REFERENCES card_info(id));');
      await db.execute(
          'CREATE TABLE image_uris(id TEXT UNIQUE PRIMARY KEY, normal TEXT, small TEXT, FOREIGN KEY(id) REFERENCES card_info(id));');
      await db.execute(
          'CREATE TABLE card_faces(id TEXT UNIQUE PRIMARY KEY, normalFront TEXT, smallFront TEXT, normalBack TEXT, smallBack TEXT, FOREIGN KEY(id) REFERENCES card_info(id))');
      await db.execute(
          'CREATE TABLE prices(id TEXT UNIQUE PRIMARY KEY, usd TEXT, usdFoil TEXT, eur TEXT, eurFoil TEXT, FOREIGN KEY(id) REFERENCES card_info(id))');
      await db.execute(
          'CREATE TABLE purchase_uris(id TEXT UNIQUE PRIMARY KEY, tcgplayer TEXT, cardmarket TEXT, FOREIGN KEY(id) REFERENCES card_info(id))');
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
    final _cardInfo = db.query('card_info', where: 'id = ?', whereArgs: [id]);
    final _cardDetail =
        db.query('card_detail', where: 'id = ?', whereArgs: [id]);
    final _imageUris = db.query('image_uris', where: 'id = ?', whereArgs: [id]);
    final _cardFaces = db.query('card_faces', where: 'id = ?', whereArgs: [id]);
    final _prices = db.query('prices', where: 'id = ?', whereArgs: [id]);
    final _purchaseUris =
        db.query('purchase_uris', where: 'id = ?', whereArgs: [id]);
    return {
      'card_info': _cardInfo,
      'card_detail': _cardDetail,
      'image_uris': _imageUris,
      'card_faces': _cardFaces,
      'prices': _prices,
      'purchase_uris': _purchaseUris
    };
  }

  static Future<Map<String, dynamic>> getCardByName(String name) async {
    final db = await DBHelper.cardDatabase();
    List<Map<String, dynamic>> _cardInfo =
        await db.rawQuery('SELECT * FROM card_info WHERE name LIKE \'$name\'');
    if (_cardInfo.isEmpty) {
      return {};
    }
    final String id = _cardInfo.first["id"];
    final _cardDetail =
        await db.query('card_detail', where: 'id = ?', whereArgs: [id]);
    final _imageUris =
        await db.query('image_uris', where: 'id = ?', whereArgs: [id]);
    final _cardFaces =
        await db.query('card_faces', where: 'id = ?', whereArgs: [id]);
    final _prices = await db.query('prices', where: 'id = ?', whereArgs: [id]);
    final _purchaseUris =
        await db.query('purchase_uris', where: 'id = ?', whereArgs: [id]);
    return {
      'card_info': _cardInfo.first,
      'card_detail': _cardDetail,
      'image_uris': _imageUris.first,
      'card_faces': _cardFaces.first,
      'prices': _prices.first,
      'purchase_uris': _purchaseUris.first,
    };
  }

  static Future<List<Map<String, dynamic>>> getCardsByName(String name) async {
    final db = await DBHelper.cardDatabase();
    List<Map<String, dynamic>> _cardDetail = await db
        .rawQuery('SELECT * FROM card_detail WHERE name LIKE \'%$name%\'');
    if (_cardDetail.isEmpty) {
      return [];
    }

    final List<Map<String, dynamic>> retList = [];
    for (int i = 0; i < _cardDetail.length; i++) {
      // print(_cardInfo[i]);
      final String id = _cardDetail[i]["id"];
      // retList.add(await DBHelper.getCardById(id));
      final _cardInfo =
          await db.query('card_info', where: 'id = ?', whereArgs: [id]);
      final _imageUris =
          await db.query('image_uris', where: 'id = ?', whereArgs: [id]);
      final _cardFaces =
          await db.query('card_faces', where: 'id = ?', whereArgs: [id]);
      final _prices =
          await db.query('prices', where: 'id = ?', whereArgs: [id]);
      final _purchaseUris =
          await db.query('purchase_uris', where: 'id = ?', whereArgs: [id]);
      retList.add({
        'card_info': _cardInfo,
        'card_detail': _cardDetail[i],
        'image_uris': _imageUris.first,
        'card_faces': _cardFaces.first,
        'prices': _prices.first,
        'purchase_uris': _purchaseUris.first,
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
