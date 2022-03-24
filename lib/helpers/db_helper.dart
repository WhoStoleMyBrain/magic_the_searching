import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;

// CREATE TABLE my_table(id INTEGER PRIMARY KEY, name TEXT);
// CREATE TABLE second_table(id INTEGER PRIMARY KEY, second_id INTEGER, FOREIGN KEY(second_id) REFERENCES my_table(id));
//
// CREATE TABLE third_table(id INTEGER PRIMARY KEY, third_id INTEGER, FOREIGN KEY(third_id) REFERENCES my_table(id));
//
// CREATE TABLE fourth_table(id INTEGER PRIMARY KEY, FOREIGN KEY(id) REFERENCES my_table(id));
//
// INSERT INTO my_table (id, name) VALUES (1, 'Gobbo');
// INSERT INTO my_table (id, name) VALUES (2, 'Leo');
// INSERT INTO my_table (id, name) VALUES (3, 'Majo');
//
// INSERT INTO second_table (id, second_id) VALUES (1, 2);
// INSERT INTO second_table (id, second_id) VALUES (2, 1);
// INSERT INTO second_table (id, second_id) VALUES (3, 3);
//
// INSERT INTO third_table (id, third_id) VALUES (7, 2);
// INSERT INTO third_table (id, third_id) VALUES (8, 1);
// INSERT INTO third_table (id, third_id) VALUES (9, 3);

// #SELECT * FROM my_table;
//
// SELECT * FROM my_table inner join second_table on my_table.id = second_table.second_id inner join third_table on my_table.id = third_table.third_id;
//
// SELECT my_table.id, my_table.name, sec.second_id, thi.third_id FROM my_table inner join second_table as sec on my_table.id = sec.second_id inner join third_table as thi on my_table.id = thi.third_id;
//
// SELECT my_table.id, my_table.name, sec.second_id, thi.third_id, fou.id FROM my_table inner join second_table as sec on my_table.id = sec.second_id inner join third_table as thi on my_table.id = thi.third_id inner join fourth_table as fou on my_table.id = fou.id;

class DBHelper {
  static Future<sql.Database> cardDatabase() async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(path.join(dbPath, 'cardDatabase.db'),
        onCreate: (db, version) async {
      await db.execute(
          'CREATE TABLE card_info(id TEXT UNIQUE PRIMARY KEY, name TEXT, oracleId TEXT, oracleText TEXT, scryfallUri TEXT, hasTwoSides INTEGER, dateTime DATETIME);');
      await db.execute(
          'CREATE TABLE image_uris(id TEXT UNIQUE PRIMARY KEY, normal TEXT, small TEXT, FOREIGN KEY(id) REFERENCES card_info(id));');
      await db.execute(
          'CREATE TABLE card_faces(id TEXT UNIQUE PRIMARY KEY, normalFront TEXT, smallFront TEXT, normalBack TEXT, smallBack TEXT, FOREIGN KEY(id) REFERENCES card_info(id))');
      await db.execute(
          'CREATE TABLE prices(id TEXT UNIQUE PRIMARY KEY, usd TEXT, usdFoil TEXT, eur TEXT, eurFoil TEXT, FOREIGN KEY(id) REFERENCES card_info(id))');
      await db.execute(
          'CREATE TABLE purchase_uris(id TEXT UNIQUE PRIMARY KEY, tcgPlayer TEXT, cardmarket TEXT, FOREIGN KEY(id) REFERENCES card_info(id))');
    }, version: 1);
  }

  static Future<void> insertIntoCardDatabase(Map<String, dynamic> data) async {
    final db = await DBHelper.cardDatabase();
    db.insert('card_info', data["card_info"] ?? {},
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

  static Future<void> insertBulkDataIntoCardDatabase(List<Map<String, dynamic>> dataList) async {
    final db = await DBHelper.cardDatabase();
    var batch = db.batch();
    for (Map<String, dynamic> data in dataList) {
      batch.insert('card_info', data["card_info"] ?? {},
          conflictAlgorithm: sql.ConflictAlgorithm.replace, nullColumnHack: 'id');
      batch.insert('image_uris', data["image_uris"] ?? {},
          conflictAlgorithm: sql.ConflictAlgorithm.replace, nullColumnHack: 'id');
      batch.insert('card_faces', data["card_faces"] ?? {},
          conflictAlgorithm: sql.ConflictAlgorithm.replace, nullColumnHack: 'id');
      batch.insert('prices', data["prices"] ?? {},
          conflictAlgorithm: sql.ConflictAlgorithm.replace, nullColumnHack: 'id');
      batch.insert('purchase_uris', data["purchase_uris"] ?? {},
          conflictAlgorithm: sql.ConflictAlgorithm.replace, nullColumnHack: 'id');
    }
    await batch.commit(noResult: true);
  }


  static Future<Map<String, dynamic>> getCardById(String id) async {
    final db = await DBHelper.cardDatabase();
    final _cardInfo = db.query('card_info', where: 'id = ?', whereArgs: [id]);
    final _imageUris = db.query('image_uris', where: 'id = ?', whereArgs: [id]);
    final _cardFaces = db.query('card_faces', where: 'id = ?', whereArgs: [id]);
    final _prices = db.query('prices', where: 'id = ?', whereArgs: [id]);
    final _purchaseUris =
        db.query('purchase_uris', where: 'id = ?', whereArgs: [id]);
    return {
      'card_info': _cardInfo,
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
    final _imageUris =
        await db.query('image_uris', where: 'id = ?', whereArgs: [id]);
    final _cardFaces =
        await db.query('card_faces', where: 'id = ?', whereArgs: [id]);
    final _prices = await db.query('prices', where: 'id = ?', whereArgs: [id]);
    final _purchaseUris =
        await db.query('purchase_uris', where: 'id = ?', whereArgs: [id]);
    return {
      'card_info': _cardInfo.first,
      'image_uris': _imageUris.first,
      'card_faces': _cardFaces.first,
      'prices': _prices.first,
      'purchase_uris': _purchaseUris.first,
    };
  }

  static Future<List<Map<String, dynamic>>> getCardsByName(String name) async {
    final db = await DBHelper.cardDatabase();
    List<Map<String, dynamic>> _cardInfo = await db
        .rawQuery('SELECT * FROM card_info WHERE name LIKE \'%$name%\'');
    if (_cardInfo.isEmpty) {
      return [];
    }

    final List<Map<String, dynamic>> retList = [];
    for (int i = 0; i < _cardInfo.length; i++) {
      final String id = _cardInfo[i]["id"];
      // retList.add(await DBHelper.getCardById(id));
      final _imageUris =
      await db.query('image_uris', where: 'id = ?', whereArgs: [id]);
      final _cardFaces =
      await db.query('card_faces', where: 'id = ?', whereArgs: [id]);
      final _prices = await db.query('prices', where: 'id = ?', whereArgs: [id]);
      final _purchaseUris =
      await db.query('purchase_uris', where: 'id = ?', whereArgs: [id]);
      retList.add({
        'card_info': _cardInfo[i],
        'image_uris': _imageUris.first,
        'card_faces': _cardFaces.first,
        'prices': _prices.first,
        'purchase_uris': _purchaseUris.first,
      });
    }
    return retList;
  }

  static Future<sql.Database> database2() async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(path.join(dbPath, 'searches.db'),
        onCreate: (db, version) async {
      await db.execute(
          'CREATE TABLE user_searches(searchText TEXT, id TEXT PRIMARY KEY, name TEXT, text TEXT, hasTwoSides BIT, requestTime DATETIME, isFromVersions BIT)');
      await db.execute(
          'CREATE TABLE search_images(searchText TEXT, id TEXT PRIMARY KEY, frontImage TEXT, backImage TEXT, requestTime DATETIME)');
      await db.execute(
          'CREATE TABLE search_prices(searchText TEXT, id TEXT PRIMARY KEY, tcg TEXT, tcgFoil TEXT, cdm TEXT, cdmFoil TEXT, requestTime DATETIME)');
      await db.execute(
          'CREATE TABLE search_links(searchText TEXT, id TEXT PRIMARY KEY, tcg TEXT, cardmarket TEXT, scryfall TEXT, requestTime DATETIME)');
    }, version: 1);
  }

  static Future<void> insert2(String table, Map<String, dynamic> data) async {
    final db = await DBHelper.database2();
    db.insert('user_searches', data["user_searches"] ?? {},
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    db.insert('search_images', data["search_images"] ?? {},
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    db.insert('search_prices', data["search_prices"] ?? {},
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    db.insert('search_links', data["search_links"] ?? {},
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, dynamic>>> getData(
    String table,
    String column,
    String searchText,
  ) async {
    final db = await DBHelper.database2();
    return db.query(table, where: '$column = ?', whereArgs: [searchText]);
  }

  static Future<List<Map<String, dynamic>>> getHistoryData() async {
    final db = await DBHelper.database2();
    var history = await db.rawQuery(
        'SELECT searchText, COUNT(*) as count, requestTime from user_searches GROUP BY searchText ORDER BY requestTime DESC');
    return history;
  }

  static Future<List<Map<String, dynamic>>> getVersionsOrPrintsData() async {
    final db = await DBHelper.database2();
    var history = await db.rawQuery(
        'SELECT name, searchText FROM user_searches WHERE user_searches.name = user_searches.searchText AND isFromVersions = 1');
    return history;
  }

  static Future<void> cleanDB() async {
    final db = await DBHelper.database2();
    await db.execute(
        "DELETE FROM search_images WHERE requestTime <= datetime('now', '-7 day')");
    await db.execute(
        "DELETE FROM search_prices WHERE requestTime <= datetime('now', '-7 day')");
    await db.execute(
        "DELETE FROM user_searches WHERE requestTime <= datetime('now', '-7 day')");
    await db.execute(
        "DELETE FROM search_links WHERE requestTime <= datetime('now', '-7 day')");
  }
}
