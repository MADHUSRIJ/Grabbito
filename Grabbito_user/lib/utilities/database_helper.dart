import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static const _databaseName = "MyCart.db";
  static const _databaseVersion = 1;

  static const table = 'my_cart';

  static const columnId = '_id';
  static const columnProId = 'pro_id';
  static const columnProName = 'pro_name';
  static const columnProImageUrl = 'pro_image';
  static const columnProType = 'pro_type';
  static const columnProQty = 'pro_qty';

  static const columnRestId = 'restId';
  static const columnRestName = 'restName';
  static const columnRestImage = 'restImage';
  static const columnRestAddress = 'restAddress';
  static const columnRestKm = 'restKm';
  static const columnRestEstimateTime = 'restEstimateTime';
  static const columnProPrice = 'pro_price';
  static const columnProCustomization = 'pro_customization';
  static const columnIsRepeatCustomization = 'isRepeatCustomization';
  static const columnIsCustomization = 'isCustomization';
  static const columnItemQty = 'itemQty';
  static const columnItemTempPrice = 'itemTempPrice';
  static const columnCurrentPriceWithoutCustomization = 'cPriceWithoutCust';

  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database!;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // int proId,String proPrice,String proName, String proImage,int proQty,int restId,String restName

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY,
            $columnProId INTEGER NOT NULL,
            $columnProPrice TEXT NOT NULL,
            $columnProName TEXT NOT NULL,
            $columnProImageUrl TEXT NOT NULL,
            $columnProType TEXT,
            $columnProQty INTEGER NOT NULL,
            $columnRestId INTEGER NOT NULL,
            $columnItemQty INTEGER NOT NULL,
            $columnRestName TEXT NOT NULL,
            $columnRestImage TEXT NOT NULL,
            $columnRestAddress TEXT NOT NULL,
            $columnRestKm TEXT NOT NULL,
            $columnRestEstimateTime TEXT NOT NULL,
            $columnIsRepeatCustomization INTEGER,
            $columnIsCustomization INTEGER,
            $columnItemTempPrice INTEGER,
            $columnProCustomization TEXT,
            $columnCurrentPriceWithoutCustomization TEXT
          )
          ''');
  }

  // Helper methods

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  Future<int> deleteTable() async {
    Database db = await (instance.database);
    return await db.delete(table);
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(table);
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int?> queryRowCount() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $table'));
  }

  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  Future<int?> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    if (row[columnProQty] == 0) {
      delete(row[columnProId]);
    } else {
      int? id = row[columnProId];
      return await db
          .update(table, row, where: '$columnProId = ?', whereArgs: [id]);
    }
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnProId = ?', whereArgs: [id]);
  }
}
